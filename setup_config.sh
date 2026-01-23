#!/bin/bash
# =============================================================================
# audit.nvim 配置设置脚本
# 自动创建 Neovim 配置文件和插件配置
# =============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo -e "${BLUE}audit.nvim 配置设置${NC}"
echo "=========================================="
echo ""

NVIM_CONFIG="$HOME/.config/nvim"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 创建目录
echo -e "${BLUE}创建配置目录...${NC}"
mkdir -p "$NVIM_CONFIG/lua/plugins"
mkdir -p "$NVIM_CONFIG/plugin"

# 创建或更新 init.lua
if [ -f "$NVIM_CONFIG/init.lua" ]; then
    echo -e "${YELLOW}init.lua 已存在，创建备份...${NC}"
    cp "$NVIM_CONFIG/init.lua" "$NVIM_CONFIG/init.lua.backup.$(date +%Y%m%d_%H%M%S)"
fi

echo -e "${BLUE}创建 init.lua...${NC}"
cat > "$NVIM_CONFIG/init.lua" << 'EOF'
-- ============================================================================
-- audit.nvim Neovim 配置
-- ============================================================================

-- 基本设置
vim.g.mapleader = ","  -- 设置 leader 键为逗号
vim.g.maplocalleader = ","

-- 编辑器选项
vim.opt.number = true           -- 显示行号
vim.opt.relativenumber = false  -- 不使用相对行号
vim.opt.mouse = 'a'             -- 启用鼠标
vim.opt.clipboard = 'unnamedplus' -- 使用系统剪贴板
vim.opt.ignorecase = true       -- 搜索时忽略大小写
vim.opt.smartcase = true        -- 智能大小写搜索
vim.opt.expandtab = true        -- 使用空格代替 tab
vim.opt.shiftwidth = 4          -- 缩进宽度
vim.opt.tabstop = 4             -- Tab 宽度
vim.opt.termguicolors = true    -- 启用真彩色

-- ============================================================================
-- 安装 lazy.nvim 插件管理器
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("正在安装 lazy.nvim...")
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  print("lazy.nvim 安装完成！")
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- 加载插件配置
-- ============================================================================
require("lazy").setup("plugins", {
  defaults = { lazy = false },
  install = { colorscheme = { "default" } },
  checker = { enabled = false },
  change_detection = { enabled = true, notify = false },
})
EOF

# 创建插件配置
echo -e "${BLUE}创建插件配置...${NC}"
cat > "$NVIM_CONFIG/lua/plugins/audit.lua" << 'EOF'
-- audit.nvim 插件配置

return {
  -- 必需插件
  {
    'skywind3000/asyncrun.vim',
    lazy = false,  -- 启动时立即加载，确保 F2 键可用
    priority = 1000,
  },

  {
    'stevearc/aerial.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('aerial').setup({
        backends = { "lsp", "treesitter", "markdown" },
        layout = { default_direction = "left", width = 30 },
      })
    end,
  },

  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- 使用新的 vim.lsp.config API (Neovim 0.11+)
      if vim.fn.executable('clangd') == 1 then
        vim.lsp.config.clangd = {
          cmd = { 'clangd' },
          filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
        }
        vim.lsp.enable('clangd')
      end
      if vim.fn.executable('pyright') == 1 then
        vim.lsp.config.pyright = {
          cmd = { 'pyright-langserver', '--stdio' },
          filetypes = { 'python' },
        }
        vim.lsp.enable('pyright')
      end
    end,
  },

  -- 推荐插件
  { 'junegunn/fzf', build = './install --all' },
  { 'junegunn/fzf.vim', dependencies = { 'junegunn/fzf' } },
  { 'MattesGroeger/vim-bookmarks' },
}
EOF

echo -e "${GREEN}✓${NC} 配置文件创建完成"
echo ""

# 创建符号链接
echo -e "${BLUE}创建符号链接...${NC}"

if [ -L "$NVIM_CONFIG/plugin/audit.vim" ]; then
    echo -e "${YELLOW}audit.vim 链接已存在${NC}"
else
    ln -sf "$SCRIPT_DIR/plugin/audit.vim" "$NVIM_CONFIG/plugin/audit.vim"
    echo -e "${GREEN}✓${NC} 创建 plugin/audit.vim 链接"
fi

if [ -L "$NVIM_CONFIG/lua/audit.lua" ]; then
    echo -e "${YELLOW}audit.lua 链接已存在${NC}"
else
    ln -sf "$SCRIPT_DIR/lua/audit.lua" "$NVIM_CONFIG/lua/audit.lua"
    echo -e "${GREEN}✓${NC} 创建 lua/audit.lua 链接"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}配置设置完成！${NC}"
echo "=========================================="
echo ""
echo "下一步："
echo "1. 打开 Neovim: nvim"
echo "2. lazy.nvim 会自动安装"
echo "3. 等待插件安装完成"
echo "4. 重启 Neovim"
echo "5. 运行 ./check_plugins.sh 验证"
echo ""
echo "提示: 首次启动时，lazy.nvim 会自动下载和安装所有插件"
echo ""
