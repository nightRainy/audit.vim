#!/bin/bash
# =============================================================================
# audit.nvim 插件检查脚本
# 检查所有必需的 Neovim 插件是否已安装
# =============================================================================

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=========================================="
echo -e "${BLUE}audit.nvim 插件检查${NC}"
echo "=========================================="
echo ""

# 检查 Neovim
if ! command -v nvim &> /dev/null; then
    echo -e "${RED}✗${NC} Neovim 未安装"
    exit 1
fi
echo -e "${GREEN}✓${NC} Neovim 已安装: $(nvim --version | head -n1)"

# 检查插件
check_plugin() {
    local plugin_name=$1
    local check_command=$2
    local install_name=$3

    result=$(nvim --headless +"${check_command}" +qa 2>&1)

    if [[ "$result" == "1" ]]; then
        echo -e "${GREEN}✓${NC} ${plugin_name} 已安装"
        return 0
    else
        echo -e "${RED}✗${NC} ${plugin_name} 未安装"
        if [ -n "$install_name" ]; then
            echo -e "   ${YELLOW}安装命令:${NC} ${install_name}"
        fi
        return 1
    fi
}

echo ""
echo "检查必需插件..."
echo ""

missing_plugins=0

# 检查 asyncrun.vim
if ! check_plugin "asyncrun.vim" "echo exists(':AsyncRun')" "'skywind3000/asyncrun.vim'"; then
    ((missing_plugins++))
fi

# 检查 aerial.nvim
if ! check_plugin "aerial.nvim" "echo exists(':AerialToggle')" "'stevearc/aerial.nvim'"; then
    ((missing_plugins++))
fi

# 检查 nvim-lspconfig
if ! check_plugin "nvim-lspconfig" "lua print(pcall(require, 'lspconfig') and 1 or 0)" "'neovim/nvim-lspconfig'"; then
    ((missing_plugins++))
fi

echo ""
echo "检查推荐插件..."
echo ""

# 检查 fzf.vim
check_plugin "fzf.vim" "echo exists(':FZF')" "'junegunn/fzf.vim'"

# 检查 vim-bookmarks
check_plugin "vim-bookmarks" "echo exists(':BookmarkToggle')" "'MattesGroeger/vim-bookmarks'"

echo ""
echo "检查外部工具..."
echo ""

# 检查外部工具
check_external() {
    if command -v "$1" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $1 已安装"
    else
        echo -e "${RED}✗${NC} $1 未安装"
    fi
}

check_external "rg"
check_external "fzf"
check_external "ctags"

echo ""
echo "=========================================="
if [ $missing_plugins -eq 0 ]; then
    echo -e "${GREEN}所有必需插件已安装！${NC}"
else
    echo -e "${YELLOW}缺少 $missing_plugins 个必需插件${NC}"
    echo ""
    echo "请按以下步骤安装缺失的插件："
    echo ""
    echo "1. 打开 Neovim: nvim"
    echo ""
    echo "2. 根据你的插件管理器运行相应命令："
    echo "   - lazy.nvim:   :Lazy sync"
    echo "   - packer.nvim: :PackerSync"
    echo "   - vim-plug:    :PlugInstall"
    echo ""
    echo "3. 重启 Neovim"
fi
echo "=========================================="
echo ""

exit $missing_plugins
