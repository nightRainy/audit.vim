#!/bin/bash
# =============================================================================
# clangd 配置生成脚本
# 自动为 C/C++ 项目创建 .clangd 配置以处理条件编译
# =============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_usage() {
    cat << EOF
用法: $0 [选项] <项目目录>

选项:
    -k, --kernel        Linux 内核项目配置
    -u, --uboot         U-Boot 项目配置
    -e, --embedded      嵌入式项目配置
    -m, --macros FILE   从文件中读取宏定义
    -i, --interactive   交互式添加宏定义
    -h, --help          显示帮助信息

示例:
    $0 /path/to/project                    # 基本配置
    $0 --kernel /path/to/linux             # Linux 内核
    $0 --embedded /path/to/firmware        # 嵌入式项目
    $0 --interactive /path/to/project      # 交互式配置

EOF
}

PROJECT_DIR="."
PROJECT_TYPE="generic"
MACROS_FILE=""
INTERACTIVE=false
CUSTOM_MACROS=()

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -k|--kernel)
            PROJECT_TYPE="kernel"
            shift
            ;;
        -u|--uboot)
            PROJECT_TYPE="uboot"
            shift
            ;;
        -e|--embedded)
            PROJECT_TYPE="embedded"
            shift
            ;;
        -m|--macros)
            MACROS_FILE="$2"
            shift 2
            ;;
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            PROJECT_DIR="$1"
            shift
            ;;
    esac
done

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}警告: 目录不存在: $PROJECT_DIR${NC}"
    echo "将在当前目录创建配置"
    PROJECT_DIR="."
fi

cd "$PROJECT_DIR"
echo -e "${BLUE}在目录创建 clangd 配置: $(pwd)${NC}"
echo ""

# 交互式添加宏
if [ "$INTERACTIVE" = true ]; then
    echo -e "${BLUE}交互式宏定义（输入空行结束）:${NC}"
    echo "示例: CONFIG_USB_DEBUG"
    echo ""
    while true; do
        read -p "宏名称: " macro
        if [ -z "$macro" ]; then
            break
        fi
        CUSTOM_MACROS+=("$macro")
        echo -e "${GREEN}✓${NC} 已添加: $macro"
    done
    echo ""
fi

# 从 Makefile 提取宏
extract_macros_from_makefile() {
    if [ -f "Makefile" ]; then
        echo -e "${BLUE}从 Makefile 提取宏定义...${NC}"
        # 提取 -D 参数
        grep -oE '\-D[A-Z_][A-Z0-9_]*' Makefile 2>/dev/null | sed 's/-D//' | sort -u
    fi
}

# 从 .config 提取宏（Linux 内核风格）
extract_macros_from_config() {
    if [ -f ".config" ]; then
        echo -e "${BLUE}从 .config 提取宏定义...${NC}"
        grep '^CONFIG_' .config | grep '=y' | cut -d'=' -f1 | sort -u
    fi
}

# 生成配置文件
generate_clangd_config() {
    local config_file=".clangd"

    cat > "$config_file" << 'EOF'
# clangd 配置文件
# 用于处理条件编译和宏定义

CompileFlags:
  Add:
EOF

    # 添加项目类型特定的宏
    case $PROJECT_TYPE in
        kernel)
            cat >> "$config_file" << 'EOF'
    # Linux 内核宏
    - -D__KERNEL__
    - -DCONFIG_64BIT
    - -DCONFIG_SMP
    - -DCONFIG_X86_64
    - -DCONFIG_DEBUG_KERNEL
EOF
            ;;
        uboot)
            cat >> "$config_file" << 'EOF'
    # U-Boot 宏
    - -D__UBOOT__
    - -DCONFIG_ARM
    - -DCONFIG_SYS_DEBUG
EOF
            ;;
        embedded)
            cat >> "$config_file" << 'EOF'
    # 嵌入式常用宏
    - -DDEBUG=1
    - -DENABLE_TRACE=1
    - -DCONFIG_USB_DEBUG=1
    - -DCONFIG_USB_POWER=1
EOF
            ;;
    esac

    # 添加通用调试宏
    cat >> "$config_file" << 'EOF'
    # 通用调试宏
    - -DDEBUG=1
    - -D_DEBUG=1
EOF

    # 从 Makefile 提取的宏
    local makefile_macros=$(extract_macros_from_makefile)
    if [ -n "$makefile_macros" ]; then
        echo "    # 从 Makefile 提取的宏" >> "$config_file"
        echo "$makefile_macros" | while read macro; do
            echo "    - -D$macro=1" >> "$config_file"
        done
    fi

    # 从 .config 提取的宏
    local config_macros=$(extract_macros_from_config)
    if [ -n "$config_macros" ]; then
        echo "    # 从 .config 提取的宏" >> "$config_file"
        echo "$config_macros" | head -20 | while read macro; do
            echo "    - -D$macro=1" >> "$config_file"
        done
    fi

    # 从文件读取宏
    if [ -n "$MACROS_FILE" ] && [ -f "$MACROS_FILE" ]; then
        echo "    # 从 $MACROS_FILE 读取的宏" >> "$config_file"
        while read macro; do
            if [ -n "$macro" ] && [[ ! "$macro" =~ ^# ]]; then
                echo "    - -D$macro=1" >> "$config_file"
            fi
        done < "$MACROS_FILE"
    fi

    # 添加自定义宏
    if [ ${#CUSTOM_MACROS[@]} -gt 0 ]; then
        echo "    # 自定义宏" >> "$config_file"
        for macro in "${CUSTOM_MACROS[@]}"; do
            echo "    - -D$macro=1" >> "$config_file"
        done
    fi

    # 添加配置的其余部分
    cat >> "$config_file" << 'EOF'

  # 移除可能导致问题的参数
  Remove:
    - -mabi=*
    - -march=*
    - -mcpu=*
    - -mfpu=*
    - -mthumb*

# 诊断配置
Diagnostics:
  UnusedIncludes: None
  MissingIncludes: None
  Suppress:
    - macro-redefined
    - unknown-warning-option

# 索引配置
Index:
  Background: Build
EOF

    echo -e "${GREEN}✓${NC} 已创建 .clangd 配置文件"
}

# 生成 ctags 配置
generate_ctags_config() {
    local config_file=".ctags"

    cat > "$config_file" << 'EOF'
# ctags 配置文件
# 处理宏定义

# 忽略的标识符
-I __THROW
-I __attribute__+
-I __restrict
-I __extension__

# 定义的宏
EOF

    # 添加通用宏
    echo "-D DEBUG=1" >> "$config_file"
    echo "-D _DEBUG=1" >> "$config_file"

    # 添加自定义宏
    if [ ${#CUSTOM_MACROS[@]} -gt 0 ]; then
        echo "" >> "$config_file"
        echo "# 自定义宏" >> "$config_file"
        for macro in "${CUSTOM_MACROS[@]}"; do
            echo "-D $macro=1" >> "$config_file"
        done
    fi

    cat >> "$config_file" << 'EOF'

# 选项
--recurse=yes
--c-kinds=+p
--c++-kinds=+p
--fields=+iaS
--extra=+q

# 排除
--exclude=.git
--exclude=build
--exclude=*.o
EOF

    echo -e "${GREEN}✓${NC} 已创建 .ctags 配置文件"
}

# 主流程
main() {
    echo "=========================================="
    echo -e "${BLUE}clangd 配置生成器${NC}"
    echo "=========================================="
    echo ""
    echo "项目类型: $PROJECT_TYPE"
    echo ""

    # 生成配置
    generate_clangd_config
    generate_ctags_config

    echo ""
    echo "=========================================="
    echo -e "${GREEN}配置完成！${NC}"
    echo "=========================================="
    echo ""
    echo "下一步："
    echo "1. 检查生成的 .clangd 文件"
    echo "2. 根据需要手动调整宏定义"
    echo "3. 重新索引项目: avim.py make -t -f ."
    echo "4. 重启 Neovim"
    echo ""
    echo "查看详细文档: cat CLANG_CONFIG.md"
}

main
