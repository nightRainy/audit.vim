#!/bin/bash
# =============================================================================
# audit.nvim 自动化安装脚本
# 支持 macOS 和 Linux
# =============================================================================

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

check_command() {
    if command -v "$1" &> /dev/null; then
        success "$1 已安装"
        return 0
    else
        warn "$1 未安装"
        return 1
    fi
}

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        error "不支持的操作系统: $OSTYPE"
    fi
}

# 检测 Linux 发行版
detect_linux_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# 安装 Homebrew (macOS)
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        info "安装 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

# 安装外部工具
install_external_tools() {
    local os=$(detect_os)

    info "开始安装外部命令行工具..."

    if [ "$os" = "macos" ]; then
        install_homebrew
        info "使用 Homebrew 安装工具..."

        # Neovim
        if ! check_command nvim; then
            brew install neovim
        fi

        # Universal Ctags
        if ! check_command ctags; then
            brew install universal-ctags
        fi

        # Ripgrep
        if ! check_command rg; then
            brew install ripgrep
        fi

        # FZF
        if ! check_command fzf; then
            brew install fzf
        fi

    elif [ "$os" = "linux" ]; then
        local distro=$(detect_linux_distro)
        info "检测到 Linux 发行版: $distro"

        if [ "$distro" = "ubuntu" ] || [ "$distro" = "debian" ]; then
            info "使用 apt 安装工具..."
            sudo apt update

            # Neovim
            if ! check_command nvim; then
                # 尝试从 PPA 安装最新版本
                sudo add-apt-repository ppa:neovim-ppa/unstable -y 2>/dev/null || true
                sudo apt update
                sudo apt install -y neovim
            fi

            # Universal Ctags
            if ! check_command ctags; then
                sudo apt install -y universal-ctags
            fi

            # Ripgrep
            if ! check_command rg; then
                sudo apt install -y ripgrep
            fi

            # FZF
            if ! check_command fzf; then
                sudo apt install -y fzf
            fi

        elif [ "$distro" = "fedora" ] || [ "$distro" = "rhel" ] || [ "$distro" = "centos" ]; then
            info "使用 dnf/yum 安装工具..."

            if ! check_command nvim; then
                sudo dnf install -y neovim || sudo yum install -y neovim
            fi

            if ! check_command ctags; then
                sudo dnf install -y ctags || sudo yum install -y ctags
            fi

            if ! check_command rg; then
                sudo dnf install -y ripgrep || sudo yum install -y ripgrep
            fi

            if ! check_command fzf; then
                sudo dnf install -y fzf || sudo yum install -y fzf
            fi

        elif [ "$distro" = "arch" ] || [ "$distro" = "manjaro" ]; then
            info "使用 pacman 安装工具..."

            sudo pacman -Syu --noconfirm

            if ! check_command nvim; then
                sudo pacman -S --noconfirm neovim
            fi

            if ! check_command ctags; then
                sudo pacman -S --noconfirm ctags
            fi

            if ! check_command rg; then
                sudo pacman -S --noconfirm ripgrep
            fi

            if ! check_command fzf; then
                sudo pacman -S --noconfirm fzf
            fi
        else
            warn "未识别的 Linux 发行版，请手动安装以下工具："
            echo "  - neovim"
            echo "  - universal-ctags"
            echo "  - ripgrep"
            echo "  - fzf"
        fi
    fi

    success "外部工具安装完成"
}

# 检查 Neovim 版本
check_neovim_version() {
    if ! command -v nvim &> /dev/null; then
        error "Neovim 未安装，请先安装 Neovim"
    fi

    local version=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+')
    local major=$(echo "$version" | cut -d. -f1)
    local minor=$(echo "$version" | cut -d. -f2)

    if [ "$major" -eq 0 ] && [ "$minor" -lt 5 ]; then
        error "Neovim 版本过低 ($version)，需要 0.5 或更高版本"
    fi

    success "Neovim 版本: $version"
}

# 安装 Python 依赖
install_python_deps() {
    info "安装 Python 依赖..."

    if ! command -v python3 &> /dev/null; then
        error "Python 3 未安装"
    fi

    python3 -m pip install --upgrade pip
    python3 -m pip install -U rich

    success "Python 依赖安装完成"
}

# 检测 Neovim 插件管理器
detect_plugin_manager() {
    local nvim_config="$HOME/.config/nvim"

    if [ -f "$nvim_config/lua/plugins.lua" ] || [ -f "$nvim_config/lua/plugins/init.lua" ]; then
        if grep -q "lazy" "$nvim_config/lua/plugins.lua" 2>/dev/null || \
           grep -q "lazy" "$nvim_config/lua/plugins/init.lua" 2>/dev/null || \
           grep -q "lazy" "$nvim_config/init.lua" 2>/dev/null; then
            echo "lazy.nvim"
            return
        elif grep -q "packer" "$nvim_config/lua/plugins.lua" 2>/dev/null || \
             grep -q "packer" "$nvim_config/lua/plugins/init.lua" 2>/dev/null; then
            echo "packer.nvim"
            return
        fi
    fi

    if [ -f "$nvim_config/init.vim" ]; then
        if grep -q "vim-plug" "$nvim_config/init.vim"; then
            echo "vim-plug"
            return
        fi
    fi

    echo "none"
}

# 生成 lazy.nvim 插件配置
generate_lazy_config() {
    cat << 'EOF'
-- audit.nvim 插件配置 (lazy.nvim)

return {
  -- 必需插件
  {
    'stevearc/aerial.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('aerial').setup({
        backends = { "lsp", "treesitter", "markdown" },
        layout = {
          default_direction = "left",
          width = 30,
        },
        attach_mode = "global",
        filter_kind = false,
        highlight_on_hover = true,
        manage_folds = true,
      })
    end,
  },
  {
    'skywind3000/asyncrun.vim',
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- LSP 配置示例（根据项目语言调整）
      -- C/C++
      require('lspconfig').clangd.setup{}

      -- Python
      -- require('lspconfig').pyright.setup{}

      -- JavaScript/TypeScript
      -- require('lspconfig').tsserver.setup{}

      -- Rust
      -- require('lspconfig').rust_analyzer.setup{}
    end,
  },

  -- 推荐插件
  {
    'junegunn/fzf',
    build = './install --all',
  },
  {
    'junegunn/fzf.vim',
  },
  {
    'MattesGroeger/vim-bookmarks',
  },
}
EOF
}

# 生成 packer.nvim 插件配置
generate_packer_config() {
    cat << 'EOF'
-- audit.nvim 插件配置 (packer.nvim)

return require('packer').startup(function(use)
  -- Packer 管理自己
  use 'wbthomason/packer.nvim'

  -- 必需插件
  use {
    'stevearc/aerial.nvim',
    requires = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('aerial').setup({
        backends = { "lsp", "treesitter", "markdown" },
        layout = {
          default_direction = "left",
          width = 30,
        },
        attach_mode = "global",
        filter_kind = false,
        highlight_on_hover = true,
        manage_folds = true,
      })
    end,
  }

  use 'skywind3000/asyncrun.vim'

  use {
    'neovim/nvim-lspconfig',
    config = function()
      -- LSP 配置示例
      require('lspconfig').clangd.setup{}
    end,
  }

  -- 推荐插件
  use {
    'junegunn/fzf',
    run = './install --all',
  }
  use 'junegunn/fzf.vim'
  use 'MattesGroeger/vim-bookmarks'
end)
EOF
}

# 生成 vim-plug 插件配置
generate_vimplug_config() {
    cat << 'VIMPLUG_EOF'
" audit.nvim 插件配置 (vim-plug)

call plug#begin()

" 必需插件
Plug 'stevearc/aerial.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-tree/nvim-web-devicons'
Plug 'skywind3000/asyncrun.vim'
Plug 'neovim/nvim-lspconfig'

" 推荐插件
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'MattesGroeger/vim-bookmarks'

call plug#end()

" aerial.nvim 配置
lua << LUAEOF
require('aerial').setup({
  backends = { "lsp", "treesitter", "markdown" },
  layout = {
    default_direction = "left",
    width = 30,
  },
})
LUAEOF

" LSP 配置
lua << LUAEOF
require('lspconfig').clangd.setup{}
LUAEOF
VIMPLUG_EOF
}

# 配置 Neovim 插件
configure_nvim_plugins() {
    info "配置 Neovim 插件..."

    local nvim_config="$HOME/.config/nvim"
    local plugin_manager=$(detect_plugin_manager)

    mkdir -p "$nvim_config/lua"

    info "检测到的插件管理器: $plugin_manager"

    if [ "$plugin_manager" = "lazy.nvim" ]; then
        local config_file="$nvim_config/lua/plugins/audit.lua"
        mkdir -p "$nvim_config/lua/plugins"

        if [ -f "$config_file" ]; then
            warn "配置文件已存在: $config_file"
            printf "是否覆盖? (y/N): "
            read -r reply
            echo
            if [[ ! "$reply" =~ ^[Yy]$ ]]; then
                info "跳过插件配置"
                return
            fi
        fi

        generate_lazy_config > "$config_file"
        success "已生成 lazy.nvim 配置: $config_file"

    elif [ "$plugin_manager" = "packer.nvim" ]; then
        local config_file="$nvim_config/lua/plugins/audit.lua"
        mkdir -p "$nvim_config/lua/plugins"

        if [ -f "$config_file" ]; then
            warn "配置文件已存在: $config_file"
            printf "是否覆盖? (y/N): "
            read -r reply
            echo
            if [[ ! "$reply" =~ ^[Yy]$ ]]; then
                info "跳过插件配置"
                return
            fi
        fi

        generate_packer_config > "$config_file"
        success "已生成 packer.nvim 配置: $config_file"

    elif [ "$plugin_manager" = "vim-plug" ]; then
        warn "检测到 vim-plug，请手动添加以下内容到 init.vim:"
        echo ""
        generate_vimplug_config
        echo ""

    else
        warn "未检测到插件管理器，将创建基础配置"

        # 创建基础 init.lua
        local init_lua="$nvim_config/init.lua"
        if [ ! -f "$init_lua" ]; then
            cat > "$init_lua" << 'EOF'
-- audit.nvim 基础配置
-- 请先安装插件管理器（推荐 lazy.nvim）

-- 如果使用 lazy.nvim，取消下面的注释
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
--   vim.fn.system({
--     "git",
--     "clone",
--     "--filter=blob:none",
--     "https://github.com/folke/lazy.nvim.git",
--     "--branch=stable",
--     lazypath,
--   })
-- end
-- vim.opt.rtp:prepend(lazypath)
-- require("lazy").setup("plugins")
EOF
            success "已创建基础配置: $init_lua"
        fi

        info "请安装插件管理器后重新运行安装脚本"
        info "推荐使用 lazy.nvim: https://github.com/folke/lazy.nvim"
    fi
}

# 安装 audit.nvim
install_audit_nvim() {
    info "安装 audit.nvim..."

    # 运行 make install
    make install

    success "audit.nvim 安装完成"
}

# 显示后续步骤
show_next_steps() {
    echo ""
    echo "=========================================="
    success "安装完成！"
    echo "=========================================="
    echo ""
    echo "📝 后续步骤："
    echo ""
    echo "1. 重启终端（或运行 source ~/.bashrc / source ~/.zshrc）"
    echo ""
    echo "2. 安装 Neovim 插件："

    local plugin_manager=$(detect_plugin_manager)
    if [ "$plugin_manager" = "lazy.nvim" ]; then
        echo "   打开 Neovim 后会自动安装插件"
        echo "   或手动运行: nvim +Lazy"
    elif [ "$plugin_manager" = "packer.nvim" ]; then
        echo "   nvim +PackerSync"
    elif [ "$plugin_manager" = "vim-plug" ]; then
        echo "   nvim +PlugInstall"
    else
        echo "   请先安装插件管理器（推荐 lazy.nvim）"
    fi

    echo ""
    echo "3. 安装 LSP 服务器（根据你的项目语言）："
    echo "   C/C++:     brew install llvm  或  sudo apt install clangd"
    echo "   Python:    npm install -g pyright"
    echo "   Rust:      rustup component add rust-analyzer"
    echo "   TypeScript: npm install -g typescript typescript-language-server"
    echo ""
    echo "4. 索引你的项目："
    echo "   avim.py make -t /path/to/your/project"
    echo ""
    echo "5. 打开项目："
    echo "   avim.py open /path/to/your/project"
    echo ""
    echo "📚 文档: https://github.com/your-repo/audit.nvim"
    echo ""
}

# 主函数
main() {
    echo "=========================================="
    info "audit.nvim 自动化安装脚本"
    echo "=========================================="
    echo ""

    # 检查是否在正确的目录
    if [ ! -f "avim.py" ] || [ ! -f "Makefile" ]; then
        error "请在 audit.nvim 项目根目录运行此脚本"
    fi

    # 1. 安装外部工具
    install_external_tools
    echo ""

    # 2. 检查 Neovim 版本
    check_neovim_version
    echo ""

    # 3. 安装 Python 依赖
    install_python_deps
    echo ""

    # 4. 安装 audit.nvim
    install_audit_nvim
    echo ""

    # 5. 配置 Neovim 插件
    configure_nvim_plugins
    echo ""

    # 6. 显示后续步骤
    show_next_steps
}

# 运行主函数
main "$@"
