# 快速修复指南

## 问题：AsyncRun 命令不存在

**错误信息：**
```
E492: Not an editor command: AsyncRun!
```

**原因：** asyncrun.vim 插件未安装或未正确加载。

## 解决方案

### 方法 1：检查并安装插件（推荐）

运行插件检查脚本：
```bash
./check_plugins.sh
```

这会显示哪些插件缺失，并提供安装建议。

### 方法 2：手动安装 asyncrun.vim

根据你使用的插件管理器：

#### 使用 lazy.nvim

在 `~/.config/nvim/lua/plugins/` 下创建或编辑插件配置：

```lua
return {
  {
    'skywind3000/asyncrun.vim',
  },
}
```

然后运行：
```vim
:Lazy sync
```

#### 使用 packer.nvim

在 `~/.config/nvim/lua/plugins.lua` 中添加：

```lua
use 'skywind3000/asyncrun.vim'
```

然后运行：
```vim
:PackerSync
```

#### 使用 vim-plug

在 `~/.config/nvim/init.vim` 中添加：

```vim
Plug 'skywind3000/asyncrun.vim'
```

然后运行：
```vim
:PlugInstall
```

### 方法 3：临时解决（无需 AsyncRun）

audit.vim 现在已经添加了回退机制。如果 AsyncRun 不可用，会自动使用同步搜索。

重新加载配置：
```vim
:source ~/.config/nvim/plugin/audit.vim
```

现在 F2 会使用同步搜索（可能会短暂阻塞，但仍然可用）。

## 验证安装

### 1. 检查插件是否加载

在 Neovim 中运行：
```vim
:echo exists(':AsyncRun')
```

如果输出 `2`，说明 AsyncRun 已安装。

### 2. 测试 F2 功能

1. 打开一个代码文件
2. 将光标放在一个函数名上
3. 按 `F2`
4. 应该在 quickfix 窗口中看到搜索结果

### 3. 运行完整检查

```bash
./check_plugins.sh
```

## 完整的插件配置示例

### lazy.nvim (推荐)

创建 `~/.config/nvim/lua/plugins/audit.lua`:

```lua
return {
  -- audit.nvim 必需插件
  {
    'skywind3000/asyncrun.vim',
    cmd = {'AsyncRun', 'AsyncStop'},
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
        layout = {
          default_direction = "left",
          width = 30,
        },
      })
    end,
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- 根据你的项目语言配置 LSP
      require('lspconfig').clangd.setup{}  -- C/C++
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
```

确保你的 `init.lua` 加载插件：

```lua
-- ~/.config/nvim/init.lua

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

## 常见问题

### Q1: 重启 Neovim 后还是报错

**A:** 确保：
1. 插件已正确安装：`:Lazy` (lazy.nvim) 或 `:PackerStatus` (packer.nvim)
2. 插件配置文件路径正确
3. 重新运行插件安装命令

### Q2: AsyncRun 安装了但还是不工作

**A:** 检查：
```vim
:echo &runtimepath
```

确保 asyncrun.vim 的路径在 runtimepath 中。

### Q3: 同步搜索太慢

**A:**
1. 确保安装了 ripgrep: `rg --version`
2. 安装 asyncrun.vim 以使用异步搜索
3. 考虑排除大型目录（如 node_modules, .git）

### Q4: 如何查看详细错误信息

**A:**
```vim
:messages          " 查看最近的消息
:scriptnames       " 查看已加载的脚本
:verbose map <F2>  " 查看 F2 的映射详情
```

## 获取帮助

如果问题仍然存在：

1. 运行 `./check_plugins.sh` 并记录输出
2. 在 Neovim 中运行 `:checkhealth` 查看整体健康状况
3. 提供错误信息和环境信息

---

更新时间：2026-01-22
