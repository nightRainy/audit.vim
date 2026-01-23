#!/bin/bash
# 手动安装所有常见语言的 Tree-sitter parsers
# 适用于代码审计场景

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
PARSER_DIR="$HOME/.local/share/nvim/site/parser"
QUERIES_DIR="$HOME/.local/share/nvim/site/queries"
WORK_DIR="/tmp/treesitter-install"

# 要安装的语言列表
LANGUAGES=(
    "java"
    "kotlin"
    "c"
    "cpp"
    "python"
    "javascript"
    "typescript/typescript"  # TypeScript 在子目录
    "typescript/tsx"         # TSX 也需要
    "lua"
    "bash"
    "json"
    "yaml"
    "xml"
    "go"
    "rust"
    "vim"
    "markdown"
)

# 检查编译器
check_compiler() {
    echo -e "${BLUE}检查 C 编译器...${NC}"
    if command -v clang &> /dev/null; then
        CC=clang
        echo -e "${GREEN}✓ 找到 clang${NC}"
    elif command -v gcc &> /dev/null; then
        CC=gcc
        echo -e "${GREEN}✓ 找到 gcc${NC}"
    else
        echo -e "${RED}✗ 未找到 C 编译器（gcc 或 clang）${NC}"
        echo -e "${YELLOW}请先安装 Xcode Command Line Tools:${NC}"
        echo "  xcode-select --install"
        exit 1
    fi
}

# 创建目录
create_dirs() {
    echo -e "${BLUE}创建安装目录...${NC}"
    mkdir -p "$PARSER_DIR"
    mkdir -p "$QUERIES_DIR"
    mkdir -p "$WORK_DIR"
    echo -e "${GREEN}✓ 目录已创建${NC}"
}

# 编译单个 parser
compile_parser() {
    local lang=$1
    local repo_path=$2
    local parser_name=$3

    echo -e "${BLUE}[$parser_name] 开始安装...${NC}"

    # 克隆仓库
    cd "$WORK_DIR"
    if [ -d "$parser_name" ]; then
        rm -rf "$parser_name"
    fi

    echo "  克隆仓库: https://github.com/tree-sitter/tree-sitter-${lang}.git"
    if ! git clone "https://github.com/tree-sitter/tree-sitter-${lang}.git" "$parser_name" --depth=1 --quiet 2>/dev/null; then
        echo -e "${YELLOW}  ⚠ 跳过 $parser_name (仓库不存在或网络错误)${NC}"
        return 1
    fi

    cd "$parser_name"

    # 检查源文件位置
    if [ -d "$repo_path" ]; then
        cd "$repo_path"
    fi

    # 查找 parser.c 文件
    if [ -f "src/parser.c" ]; then
        SRC_FILE="src/parser.c"
    elif [ -f "parser.c" ]; then
        SRC_FILE="parser.c"
    else
        echo -e "${YELLOW}  ⚠ 跳过 $parser_name (未找到 parser.c)${NC}"
        return 1
    fi

    # 编译
    echo "  编译..."
    if $CC -o "${parser_name}.so" -shared "$SRC_FILE" -Os -I./src 2>/dev/null; then
        # 安装
        mv "${parser_name}.so" "$PARSER_DIR/"
        echo -e "${GREEN}  ✓ $parser_name 安装成功${NC}"

        # 复制 queries（如果存在）
        if [ -d "../../queries" ]; then
            cp -r "../../queries" "$QUERIES_DIR/$parser_name" 2>/dev/null || true
        fi

        return 0
    else
        echo -e "${RED}  ✗ $parser_name 编译失败${NC}"
        return 1
    fi
}

# 主函数
main() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}Tree-sitter Parsers 批量安装${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""

    # 检查编译器
    check_compiler
    echo ""

    # 创建目录
    create_dirs
    echo ""

    # 统计
    local total=${#LANGUAGES[@]}
    local success=0
    local failed=0

    echo -e "${BLUE}准备安装 $total 个语言的 parsers...${NC}"
    echo ""

    # 安装每个语言
    for lang_spec in "${LANGUAGES[@]}"; do
        # 解析语言规格（处理 typescript/typescript 这种情况）
        IFS='/' read -r lang repo_path <<< "$lang_spec"

        # 确定 parser 名称
        if [ -z "$repo_path" ]; then
            parser_name="$lang"
            repo_path=""
        else
            parser_name="$repo_path"
        fi

        if compile_parser "$lang" "$repo_path" "$parser_name"; then
            ((success++))
        else
            ((failed++))
        fi
        echo ""
    done

    # 清理
    echo -e "${BLUE}清理临时文件...${NC}"
    rm -rf "$WORK_DIR"

    # 总结
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}安装完成！${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    echo -e "${GREEN}✓ 成功安装: $success${NC}"
    if [ $failed -gt 0 ]; then
        echo -e "${YELLOW}⚠ 跳过/失败: $failed${NC}"
    fi
    echo ""
    echo -e "安装位置: ${BLUE}$PARSER_DIR${NC}"
    echo ""
    echo "已安装的 parsers:"
    ls -1 "$PARSER_DIR" | sed 's/\.so$//' | while read -r p; do
        echo -e "  ${GREEN}✓${NC} $p"
    done
    echo ""
    echo -e "${YELLOW}现在请重启 Neovim，打开相应的代码文件即可看到语法高亮！${NC}"
}

# 运行
main
