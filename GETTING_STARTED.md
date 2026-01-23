# 快速开始指南

## 问题：No specs found for module "plugins"

这个错误表示 Neovim 找不到插件配置文件。

## 解决方案（推荐）

运行自动配置脚本：

```bash
cd /Users/zs/tools/audit.vim
./setup_config.sh
```

这个脚本会：
- ✅ 创建正确的目录结构
- ✅ 生成 `init.lua` 配置文件
- ✅ 创建插件配置 `lua/plugins/audit.lua`
- ✅ 创建符号链接到 audit.vim

## 手动解决方案

如果自动脚本不工作，按以下步骤手动配置：

### 1. 创建目录结构

```bash
mkdir -p ~/.config/nvim/lua/plugins
mkdir -p ~/.config/nvim/plugin
```

### 2. 创建 init.lua

创建 `~/.config/nvim/init.lua`:

```lua
-- 基本设置
vim.g.mapleader = ","

-- 安装 lazy.nvim
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

-- 加载插件
require("lazy").setup("plugins")
```

### 3. 创建插件配置

创建 `~/.config/nvim/lua/plugins/audit.lua`:

```lua
return {
  {
    'skywind3000/asyncrun.vim',
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
    config = function()
      require('lspconfig').clangd.setup{}
    end,
  },
  { 'junegunn/fzf', build = './install --all' },
  { 'junegunn/fzf.vim' },
  { 'MattesGroeger/vim-bookmarks' },
}
```

### 4. 创建符号链接

```bash
cd /Users/zs/tools/audit.vim
ln -sf $(pwd)/plugin/audit.vim ~/.config/nvim/plugin/audit.vim
ln -sf $(pwd)/lua/audit.lua ~/.config/nvim/lua/audit.lua
```

## 验证配置

### 1. 检查文件结构

```bash
tree ~/.config/nvim/
```

应该看到：
```
~/.config/nvim/
├── init.lua
├── lua/
│   ├── audit.lua -> /Users/zs/tools/audit.vim/lua/audit.lua
│   └── plugins/
│       └── audit.lua
└── plugin/
    └── audit.vim -> /Users/zs/tools/audit.vim/plugin/audit.vim
```

### 2. 启动 Neovim

```bash
nvim
```

**第一次启动时：**
- lazy.nvim 会自动开始安装
- 你会看到安装进度窗口
- 等待所有插件安装完成（可能需要几分钟）

**如果没有自动安装：**
```vim
:Lazy
```

然后按 `I` (Install) 安装所有插件。

### 3. 检查插件状态

```vim
:Lazy
```

所有插件应该显示为已安装（绿色 ✓）。

### 4. 测试功能

```vim
" 检查 AsyncRun
:echo exists(':AsyncRun')
" 应该输出: 2

" 检查 aerial
:AerialToggle
" 应该打开符号大纲窗口

" 检查 LSP (如果已安装 clangd)
:LspInfo
" 应该显示 LSP 服务器信息
```

### 5. 测试 F2 搜索

1. 打开一个代码文件
2. 光标放在一个函数名上
3. 按 `F2`
4. 应该在 quickfix 窗口看到搜索结果

## 运行检查脚本

```bash
cd /Users/zs/tools/audit.vim
./check_plugins.sh
```

输出应该显示所有插件都已安装：

```
==========================================
audit.nvim 插件检查
==========================================

✓ Neovim 已安装: NVIM v0.9.0

检查必需插件...

✓ asyncrun.vim 已安装
✓ aerial.nvim 已安装
✓ nvim-lspconfig 已安装
```

## 常见问题

### Q: lazy.nvim 没有自动安装

**A:** 手动触发安装：
```vim
:Lazy sync
```

### Q: 插件安装失败

**A:** 检查网络连接，然后：
```vim
:Lazy clean    " 清理
:Lazy sync     " 重新同步
```

### Q: AsyncRun 还是不工作

**A:** 确保插件已加载：
```vim
:scriptnames
```

查找 `asyncrun.vim`，如果没有找到，检查配置文件。

### Q: 如何更新插件

**A:**
```vim
:Lazy update
```

### Q: 如何卸载插件

**A:** 从 `lua/plugins/audit.lua` 中删除对应的插件配置，然后：
```vim
:Lazy clean
```

## 下一步

配置完成后：

1. **索引项目：**
   ```bash
   avim.py make -t /path/to/your/project
   ```

2. **打开项目：**
   ```bash
   avim.py open /path/to/your/project
   ```

3. **安装 LSP 服务器** (可选但推荐):
   ```bash
   # C/C++
   brew install llvm  # macOS
   sudo apt install clangd  # Linux

   # Python
   npm install -g pyright

   # Rust
   rustup component add rust-analyzer
   ```

4. **查看快捷键：**
   - `<leader>o` - 符号大纲
   - `<leader>fs` - LSP 引用查找
   - `<leader>fg` - LSP 定义跳转
   - `F2` - ripgrep 搜索
   - 查看 [README.md](README.md) 了解所有快捷键

## 获取帮助

- 查看配置问题: `./check_plugins.sh`
- AsyncRun 问题: [QUICKFIX.md](QUICKFIX.md)
- 详细安装: [INSTALL.md](INSTALL.md)

---

祝使用愉快！🚀
