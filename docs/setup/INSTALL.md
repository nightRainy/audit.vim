# audit.nvim 安装指南

本文档提供详细的安装说明，包括自动化安装和手动安装两种方式。

## 目录

- [系统要求](#系统要求)
- [快速安装](#快速安装)
- [手动安装](#手动安装)
- [插件管理器配置](#插件管理器配置)
- [LSP 服务器安装](#lsp-服务器安装)
- [故障排除](#故障排除)

## 系统要求

### 必需
- **Neovim** >= 0.5
- **Python 3** >= 3.6
- **Git**

### 推荐
- **Node.js** >= 14 (用于安装 LSP 服务器)
- **Make** (用于简化安装)

## 快速安装

### macOS / Linux

```bash
# 1. 克隆仓库
git clone https://github.com/your-repo/audit.nvim.git
cd audit.nvim

# 2. 运行自动化安装脚本
chmod +x install.sh
./install.sh
```

### Windows

```powershell
# 1. 克隆仓库
git clone https://github.com/your-repo/audit.nvim.git
cd audit.nvim

# 2. 以管理员权限运行 PowerShell
# 右键 PowerShell -> 以管理员身份运行

# 3. 运行安装脚本
.\install.ps1
```

安装脚本会自动完成以下操作：
1. 检测操作系统和包管理器
2. 安装 Neovim（如果未安装）
3. 安装外部依赖（ctags, ripgrep, fzf）
4. 安装 Python 依赖（rich）
5. 安装 audit.nvim 到 Neovim 配置目录
6. 检测并配置插件管理器

## 手动安装

如果自动化脚本无法正常工作，可以按照以下步骤手动安装。

### 1. 安装 Neovim

**macOS:**
```bash
brew install neovim
```

**Ubuntu/Debian:**
```bash
# 添加 PPA 获取最新版本
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt install neovim
```

**Arch Linux:**
```bash
sudo pacman -S neovim
```

**Windows:**
```powershell
scoop install neovim
# 或使用 Chocolatey: choco install neovim
```

### 2. 安装外部工具

**macOS:**
```bash
brew install universal-ctags ripgrep fzf
```

**Ubuntu/Debian:**
```bash
sudo apt install universal-ctags ripgrep fzf
```

**Arch Linux:**
```bash
sudo pacman -S ctags ripgrep fzf
```

**Windows:**
```powershell
scoop install universal-ctags ripgrep fzf
```

### 3. 安装 Python 依赖

```bash
python3 -m pip install -U rich
```

### 4. 安装 audit.nvim

**macOS/Linux:**
```bash
cd audit.nvim
make install
```

这会将文件链接到：
- `~/.config/nvim/plugin/audit.vim`
- `~/.config/nvim/lua/audit.lua`
- `~/.local/bin/avim.py`

**Windows:**

手动复制文件：
```powershell
# 创建目录
New-Item -ItemType Directory -Force -Path $env:LOCALAPPDATA\nvim\plugin
New-Item -ItemType Directory -Force -Path $env:LOCALAPPDATA\nvim\lua

# 复制文件
Copy-Item plugin\audit.vim $env:LOCALAPPDATA\nvim\plugin\
Copy-Item lua\audit.lua $env:LOCALAPPDATA\nvim\lua\
Copy-Item avim.py $env:USERPROFILE\.local\bin\
```

## 插件管理器配置

audit.nvim 依赖一些 Neovim 插件。选择你喜欢的插件管理器：

### lazy.nvim (推荐)

创建 `~/.config/nvim/lua/plugins/audit.lua`:

```lua
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
      })
    end,
  },
  { 'skywind3000/asyncrun.vim' },
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- 根据项目语言配置 LSP
      require('lspconfig').clangd.setup{}  -- C/C++
      -- require('lspconfig').pyright.setup{}  -- Python
      -- require('lspconfig').tsserver.setup{}  -- TypeScript
    end,
  },

  -- 推荐插件
  { 'junegunn/fzf', build = './install --all' },
  { 'junegunn/fzf.vim' },
  { 'MattesGroeger/vim-bookmarks' },
}
```

确保你的 `init.lua` 加载 lazy.nvim：

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
```

### packer.nvim

在 `~/.config/nvim/lua/plugins.lua`:

```lua
return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- audit.nvim 依赖
  use {
    'stevearc/aerial.nvim',
    requires = {'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons'},
    config = function()
      require('aerial').setup({
        backends = { "lsp", "treesitter", "markdown" },
        layout = { default_direction = "left", width = 30 },
      })
    end,
  }
  use 'skywind3000/asyncrun.vim'
  use {
    'neovim/nvim-lspconfig',
    config = function()
      require('lspconfig').clangd.setup{}
    end,
  }
  use { 'junegunn/fzf', run = './install --all' }
  use 'junegunn/fzf.vim'
  use 'MattesGroeger/vim-bookmarks'
end)
```

运行 `:PackerSync` 安装插件。

### vim-plug

在 `~/.config/nvim/init.vim`:

```vim
call plug#begin()

Plug 'stevearc/aerial.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-tree/nvim-web-devicons'
Plug 'skywind3000/asyncrun.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'MattesGroeger/vim-bookmarks'

call plug#end()

lua << EOF
require('aerial').setup({
  backends = { "lsp", "treesitter", "markdown" },
  layout = { default_direction = "left", width = 30 },
})
require('lspconfig').clangd.setup{}
EOF
```

运行 `:PlugInstall` 安装插件。

## LSP 服务器安装

audit.nvim 使用 LSP 替代 cscope。你需要为项目语言安装相应的 LSP 服务器。

### C/C++ - clangd

**macOS:**
```bash
brew install llvm
```

**Linux:**
```bash
sudo apt install clangd  # Ubuntu/Debian
sudo pacman -S clang     # Arch Linux
```

**Windows:**
```powershell
scoop install llvm
```

### Python - pyright

```bash
npm install -g pyright
```

或使用 pip:
```bash
pip install pyright
```

### JavaScript/TypeScript - tsserver

```bash
npm install -g typescript typescript-language-server
```

### Rust - rust-analyzer

```bash
rustup component add rust-analyzer
```

### Go - gopls

```bash
go install golang.org/x/tools/gopls@latest
```

### 其他语言

查看 [nvim-lspconfig 服务器配置](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md) 获取更多 LSP 服务器。

## 验证安装

### 1. 检查 Neovim 版本

```bash
nvim --version
```

应该显示 0.5 或更高版本。

### 2. 检查外部工具

```bash
nvim --version     # Neovim
ctags --version    # Universal Ctags
rg --version       # Ripgrep
fzf --version      # FZF
```

### 3. 测试 audit.nvim

```bash
# 索引一个项目
avim.py make -t /path/to/your/project

# 查看已索引的项目
avim.py info

# 打开项目
avim.py open /path/to/your/project
```

在 Neovim 中测试：
- `<leader>o` - 应该打开 aerial 符号大纲
- `<leader>fs` - 应该显示 LSP 引用（需要配置 LSP）
- `:AerialToggle` - 应该切换符号视图

## 故障排除

### Neovim 版本过低

**问题:** 显示 "audit.vim: 此版本仅支持 Neovim"

**解决:** 升级 Neovim 到 0.5 或更高版本。

### Python 依赖问题

**问题:** `ImportError: No module named 'rich'`

**解决:**
```bash
python3 -m pip install --user rich
```

### LSP 不工作

**问题:** `<leader>fs` 等快捷键没有反应

**解决:**
1. 确保安装了对应语言的 LSP 服务器
2. 检查 LSP 是否正常运行: `:LspInfo`
3. 查看日志: `:lua vim.lsp.set_log_level("debug")`
4. 重启 Neovim

### aerial.nvim 不显示

**问题:** `<leader>o` 没有反应

**解决:**
1. 确保安装了 aerial.nvim: `:Lazy` (lazy.nvim) 或 `:PackerStatus` (packer.nvim)
2. 检查配置: `:lua print(vim.inspect(require('aerial').setup))`
3. 查看是否有错误: `:messages`

### avim.py 命令找不到

**问题:** `command not found: avim.py`

**解决:**

**macOS/Linux:**
```bash
# 确保 ~/.local/bin 在 PATH 中
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # 或 ~/.zshrc
source ~/.bashrc  # 或 source ~/.zshrc
```

**Windows:**
添加 `%USERPROFILE%\.local\bin` 到系统 PATH 环境变量。

### 权限问题 (Linux/macOS)

**问题:** Permission denied

**解决:**
```bash
chmod +x ~/.local/bin/avim.py
```

## 卸载

### 自动卸载

**macOS/Linux:**
```bash
cd audit.nvim
make uninstall  # 如果有提供
```

### 手动卸载

删除以下文件和目录：

**macOS/Linux:**
```bash
rm ~/.config/nvim/plugin/audit.vim
rm ~/.config/nvim/lua/audit.lua
rm ~/.local/bin/avim.py
rm -rf ~/.audit.vim  # 索引数据
```

**Windows:**
```powershell
Remove-Item $env:LOCALAPPDATA\nvim\plugin\audit.vim
Remove-Item $env:LOCALAPPDATA\nvim\lua\audit.lua
Remove-Item $env:USERPROFILE\.local\bin\avim.py
Remove-Item -Recurse $env:USERPROFILE\.audit.vim
```

## 获取帮助

如果遇到问题：

1. 查看 [README.md](README.md) 了解基本使用
2. 检查 [Issues](https://github.com/your-repo/audit.nvim/issues)
3. 提交新的 Issue 描述你的问题

---

祝你使用愉快！🎉
