#!/usr/bin/env bash

# =============================================================================
# OpenCode AI 插件自动安装脚本
# 用于将 opencode.nvim 集成到 Neovim 配置中
# =============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检测 Neovim 配置目录
detect_nvim_config() {
    if [[ -d "$HOME/.config/nvim" ]]; then
        echo "$HOME/.config/nvim"
    elif [[ -d "$HOME/.nvim" ]]; then
        echo "$HOME/.nvim"
    else
        return 1
    fi
}

# 检测配置文件
detect_config_file() {
    local nvim_config_dir="$1"

    if [[ -f "$nvim_config_dir/init.lua" ]]; then
        echo "$nvim_config_dir/init.lua"
    elif [[ -f "$nvim_config_dir/init.vim" ]]; then
        echo "$nvim_config_dir/init.vim"
    else
        return 1
    fi
}

# 检测插件管理器
detect_plugin_manager() {
    local config_file="$1"

    if grep -q "require.*lazy" "$config_file" 2>/dev/null; then
        echo "lazy"
    elif grep -q "require.*packer" "$config_file" 2>/dev/null; then
        echo "packer"
    elif grep -q "Plug " "$config_file" 2>/dev/null; then
        echo "vim-plug"
    else
        echo "unknown"
    fi
}

# 检查是否已安装 opencode
check_already_installed() {
    local config_file="$1"

    if grep -q "opencode.nvim\|audit.opencode" "$config_file" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# 备份配置文件
backup_config() {
    local config_file="$1"
    local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"

    cp "$config_file" "$backup_file"
    log_success "配置文件已备份到: $backup_file"
    echo "$backup_file"
}

# 生成 lazy.nvim 插件配置
generate_lazy_plugin_config() {
    cat <<'EOF'

-- OpenCode AI 插件配置（由 install_opencode.sh 自动添加）
{
  "NickvanDyke/opencode.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "folke/snacks.nvim",
      opts = {
        input = {},
        picker = {},
        terminal = {},
      },
    },
  },
  config = function()
    -- 配置会由 audit.opencode 模块处理
  end,
},
EOF
}

# 生成 packer.nvim 插件配置
generate_packer_plugin_config() {
    cat <<'EOF'

-- OpenCode AI 插件配置（由 install_opencode.sh 自动添加）
use {
  "NickvanDyke/opencode.nvim",
  requires = {
    "nvim-lua/plenary.nvim",
    {
      "folke/snacks.nvim",
      config = function()
        require("snacks").setup({
          input = {},
          picker = {},
          terminal = {},
        })
      end,
    },
  },
}
EOF
}

# 生成 vim-plug 插件配置
generate_vimplug_plugin_config() {
    cat <<'EOF'

" OpenCode AI 插件配置（由 install_opencode.sh 自动添加）
Plug 'nvim-lua/plenary.nvim'
Plug 'folke/snacks.nvim'
Plug 'NickvanDyke/opencode.nvim'
EOF
}

# 生成 OpenCode 初始化配置
generate_opencode_init_config() {
    cat <<'EOF'

-- =============================================================================
-- OpenCode AI 配置（由 install_opencode.sh 自动添加）
-- =============================================================================

local opencode_config = require('audit.opencode')

if opencode_config.check_cli() then
  -- 设置 OpenCode
  opencode_config.setup({
    keymaps = {
      ask = "<C-a>",      -- 询问 AI
      select = "<C-x>",   -- 选择动作
      toggle = "<C-.>",   -- 切换终端
    },
  })

  -- 设置内置命令
  opencode_config.setup_commands()

  vim.notify("OpenCode AI 已启用", vim.log.levels.INFO)
else
  vim.notify("OpenCode CLI 未安装，请先安装: https://github.com/sst/opencode", vim.log.levels.WARN)
end

-- 可用快捷键:
--   <C-a>  - 询问 AI（普通模式和可视模式）
--   <C-x>  - 选择动作
--   <C-.>  - 切换 opencode 终端
--
-- 可用命令:
--   :OpencodeExplain             - 解释代码
--   :OpencodeReview              - 代码审查
--   :OpencodeOptimize            - 优化代码
--   :OpencodeFix                 - 修复诊断问题
--   :OpencodeDocument            - 添加文档
--   :OpencodeTest                - 添加测试
--   :OpencodeAsk [prompt]        - 自由提问
--
-- 查看状态:
--   :lua require('audit.opencode').show_status()
--
-- 启动服务器:
--   :lua require('audit.opencode').start_server()
--
-- =============================================================================
EOF
}

# 添加插件到 lazy.nvim 配置
add_to_lazy_config() {
    local config_file="$1"
    local temp_file=$(mktemp)

    # 查找 require("lazy").setup({ 的位置
    local line_num=$(grep -n 'require.*lazy.*setup.*{' "$config_file" | head -1 | cut -d: -f1)

    if [[ -z "$line_num" ]]; then
        log_error "找不到 lazy.nvim 的 setup 调用"
        return 1
    fi

    # 在插件列表中添加 opencode
    awk -v line="$line_num" -v plugin="$(generate_lazy_plugin_config)" '
        NR == line + 1 { print plugin }
        { print }
    ' "$config_file" > "$temp_file"

    mv "$temp_file" "$config_file"
    log_success "已添加 opencode.nvim 插件到 lazy.nvim 配置"
}

# 添加插件到 packer.nvim 配置
add_to_packer_config() {
    local config_file="$1"
    local temp_file=$(mktemp)

    # 查找 packer.startup 的位置
    local line_num=$(grep -n 'packer\.startup\|use_rocks' "$config_file" | head -1 | cut -d: -f1)

    if [[ -z "$line_num" ]]; then
        log_error "找不到 packer.nvim 的配置"
        return 1
    fi

    # 在插件列表中添加 opencode
    awk -v line="$line_num" -v plugin="$(generate_packer_plugin_config)" '
        NR == line + 1 { print plugin }
        { print }
    ' "$config_file" > "$temp_file"

    mv "$temp_file" "$config_file"
    log_success "已添加 opencode.nvim 插件到 packer.nvim 配置"
}

# 添加插件到 vim-plug 配置
add_to_vimplug_config() {
    local config_file="$1"
    local temp_file=$(mktemp)

    # 查找 call plug#begin 之后的位置
    local line_num=$(grep -n "call plug#begin" "$config_file" | head -1 | cut -d: -f1)

    if [[ -z "$line_num" ]]; then
        log_error "找不到 vim-plug 的配置"
        return 1
    fi

    # 在插件列表中添加 opencode
    awk -v line="$line_num" -v plugin="$(generate_vimplug_plugin_config)" '
        NR == line + 1 { print plugin }
        { print }
    ' "$config_file" > "$temp_file"

    mv "$temp_file" "$config_file"
    log_success "已添加 opencode.nvim 插件到 vim-plug 配置"
}

# 添加 OpenCode 初始化配置
add_opencode_init() {
    local config_file="$1"

    # 直接追加到文件末尾
    echo "$(generate_opencode_init_config)" >> "$config_file"
    log_success "已添加 OpenCode 初始化配置"
}

# 检查 OpenCode CLI
check_opencode_cli() {
    if command -v opencode &> /dev/null; then
        local version=$(opencode --version 2>&1 | head -1)
        log_success "OpenCode CLI 已安装: $version"
        return 0
    else
        log_warning "OpenCode CLI 未安装"
        log_info "请访问 https://github.com/sst/opencode 安装 CLI"
        return 1
    fi
}

# 主函数
main() {
    echo "=========================================="
    echo "  OpenCode AI 插件安装脚本"
    echo "=========================================="
    echo ""

    # 1. 检测 Neovim 配置目录
    log_info "检测 Neovim 配置目录..."
    nvim_config_dir=$(detect_nvim_config)

    if [[ -z "$nvim_config_dir" ]]; then
        log_error "找不到 Neovim 配置目录"
        log_info "请创建 ~/.config/nvim 目录"
        exit 1
    fi

    log_success "找到配置目录: $nvim_config_dir"

    # 2. 检测配置文件
    log_info "检测配置文件..."
    config_file=$(detect_config_file "$nvim_config_dir")

    if [[ -z "$config_file" ]]; then
        log_warning "找不到配置文件，将创建 init.lua"
        config_file="$nvim_config_dir/init.lua"
        touch "$config_file"
    fi

    log_success "配置文件: $config_file"

    # 3. 检查是否已安装
    log_info "检查是否已安装 opencode..."
	log_info "config file path is $config_file"
    if check_already_installed "$config_file"; then
        log_warning "OpenCode 配置已存在于配置文件中"
        read -p "是否继续安装？这可能导致重复配置 (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "安装已取消"
            exit 0
        fi
    fi

    # 4. 备份配置文件
    log_info "备份配置文件..."
    backup_file=$(backup_config "$config_file")

    # 5. 检测插件管理器
    log_info "检测插件管理器..."
    plugin_manager=$(detect_plugin_manager "$config_file")
    log_success "检测到插件管理器: $plugin_manager"

    # 6. 添加插件配置
    log_info "添加 opencode.nvim 插件配置..."

    case "$plugin_manager" in
        lazy)
            add_to_lazy_config "$config_file" || {
                log_error "添加插件配置失败"
                log_info "恢复备份..."
                cp "$backup_file" "$config_file"
                exit 1
            }
            ;;
        packer)
            add_to_packer_config "$config_file" || {
                log_error "添加插件配置失败"
                log_info "恢复备份..."
                cp "$backup_file" "$config_file"
                exit 1
            }
            ;;
        vim-plug)
            add_to_vimplug_config "$config_file" || {
                log_error "添加插件配置失败"
                log_info "恢复备份..."
                cp "$backup_file" "$config_file"
                exit 1
            }
            ;;
        unknown)
            log_warning "未检测到插件管理器，将手动添加插件配置"
            log_info "请手动添加 opencode.nvim 到你的插件管理器"
            ;;
    esac

    # 7. 添加 OpenCode 初始化配置
    log_info "添加 OpenCode 初始化配置..."
	echo $config_file
    add_opencode_init "$config_file"

    # 8. 检查 OpenCode CLI
    log_info "检查 OpenCode CLI..."
    check_opencode_cli

    # 9. 完成
    echo ""
    echo "=========================================="
    log_success "安装完成！"
    echo "=========================================="
    echo ""
    echo "下一步："
    echo "  1. 重启 Neovim 或运行 :source $config_file"

    if [[ "$plugin_manager" == "lazy" ]]; then
        echo "  2. Lazy.nvim 会自动安装插件"
    elif [[ "$plugin_manager" == "packer" ]]; then
        echo "  2. 运行 :PackerSync 安装插件"
    elif [[ "$plugin_manager" == "vim-plug" ]]; then
        echo "  2. 运行 :PlugInstall 安装插件"
    fi

    echo "  3. 如果 OpenCode CLI 未安装，请先安装："
    echo "     https://github.com/sst/opencode"
    echo "  4. 启动 OpenCode 服务器："
    echo "     :lua require('audit.opencode').start_server()"
    echo "  5. 开始使用："
    echo "     - 按 <C-a> 询问 AI"
    echo "     - 按 <C-x> 选择动作"
    echo "     - 运行 :OpencodeReview 审查代码"
    echo ""
    echo "配置文件备份: $backup_file"
    echo "如有问题，可以使用备份恢复配置"
    echo ""
    echo "更多信息请参考:"
    echo "  - OPENCODE_QUICKSTART.md"
    echo "  - example_config.lua"
    echo ""
}

# 运行主函数
main "$@"
