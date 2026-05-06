# OpenCode AI 快速开始指南

本指南帮助你快速在 audit.nvim 中启用 OpenCode AI 编程助手。

## 前置条件

1. ✅ 已安装 Neovim 0.5+
2. ✅ 已安装 audit.nvim 插件
3. ✅ 已安装必需的插件（aerial.nvim, asyncrun.vim, nvim-lspconfig）

## 第一步：安装 OpenCode CLI

访问 [OpenCode 官方仓库](https://github.com/sst/opencode) 并按照说明安装 CLI。

验证安装：
```bash
opencode --version
```

## 第二步：安装 opencode.nvim 插件

在你的插件管理器配置中添加（以 lazy.nvim 为例）：

```lua
{
  "NickvanDyke/opencode.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
}
```

## 第三步：配置 OpenCode

在 `~/.config/nvim/init.lua` 中添加：

```lua
-- 方法 1：使用 audit.nvim 的集成配置（推荐）
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

  -- 设置便捷命令
  opencode_config.setup_commands()

  print("OpenCode AI 已启用")
else
  print("OpenCode CLI 未安装，跳过配置")
end
```

或者：

```lua
-- 方法 2：通过 audit.setup() 统一配置
local audit = require('audit')
audit.setup({
  opencode = {
    keymaps = {
      ask = "<C-a>",
      select = "<C-x>",
      toggle = "<C-.>",
    },
  },
})
```

## 第四步：重启 Neovim

```vim
:qa
nvim
```

或重新加载配置：
```vim
:source ~/.config/nvim/init.lua
```

## 第五步：启动 OpenCode 服务器

在 Neovim 中运行：

```vim
:lua require('audit.opencode').start_server()
```

或在终端中手动启动：
```bash
opencode --port 6041
```

## 第六步：开始使用

### 基本使用

1. **询问 AI**
   - 普通模式下按 `<C-a>`，输入问题
   - 可视模式下选中代码，按 `<C-a>`，AI 会包含代码上下文

2. **选择动作**
   - 按 `<C-x>` 打开动作选择器
   - 选择预设的提示词（explain, review, optimize 等）

3. **切换终端**
   - 按 `<C-.>` 切换 OpenCode 终端窗口

### 使用命令

```vim
" 解释当前代码
:OpencodeExplain

" 审查代码质量
:OpencodeReview

" 优化代码性能
:OpencodeOptimize

" 修复诊断问题
:OpencodeFix

" 添加文档注释
:OpencodeDocument

" 生成测试代码
:OpencodeTest

" 自由提问
:OpencodeAsk 如何优化这段代码？
```

### 在可视模式下使用

```vim
" 1. 进入可视模式（v 或 V）
" 2. 选中你想处理的代码
" 3. 运行命令
:'<,'>OpencodeReview
:'<,'>OpencodeOptimize
```

## 实用技巧

### 使用上下文占位符

在提问时可以使用占位符引用编辑器上下文：

```
@this         - 当前选区或光标位置
@buffer       - 当前文件
@buffers      - 所有打开的文件
@diagnostics  - LSP 诊断信息
@quickfix     - quickfix 列表
@diff         - Git diff
```

示例：
```vim
:OpencodeAsk 解释 @this 的工作原理
:OpencodeAsk 检查 @diagnostics 中的错误
```

### 查看状态

```vim
:lua require('audit.opencode').show_status()
```

输出示例：
```
OpenCode Status:
================
CLI Installed: ✓
CLI Version: 1.0.0
Plugin Loaded: ✓

Available Commands:
  :OpencodeExplainDiagnostics
  :OpencodeFix
  :OpencodeExplain
  ...
```

### 自定义提示词

在 `init.lua` 中添加：

```lua
vim.g.opencode_opts = {
  prompts = {
    -- 自定义提示词
    security = {
      template = "Check @this for security vulnerabilities",
    },
    refactor = {
      template = "Refactor @this to improve code quality",
    },
  },
}
```

## 常见问题

### Q: 按 `<C-a>` 没反应？
A: 检查：
1. OpenCode CLI 是否已安装：`opencode --version`
2. OpenCode 服务器是否运行：`:lua require('audit.opencode').start_server()`
3. 插件是否加载：`:lua print(pcall(require, 'opencode'))`

### Q: 提示 "OpenCode CLI not found"？
A: 需要先安装 OpenCode CLI，访问 https://github.com/NickvanDyke/opencode

### Q: 如何更改快捷键？
A: 在配置中修改 `keymaps`：
```lua
opencode_config.setup({
  keymaps = {
    ask = "<leader>oa",     -- 改为 <leader>oa
    select = "<leader>ox",  -- 改为 <leader>ox
    toggle = "<leader>ot",  -- 改为 <leader>ot
  },
})
```

### Q: 与 aerial 的 `<leader>o` 冲突？
A: audit.vim 中 aerial 使用 `<leader>o`，OpenCode 使用 `<C-a>/<C-x>/<C-.>`，不会冲突。
如果你自定义了快捷键导致冲突，可以修改其中一个。

## 完整配置示例

参考项目中的 `example_config.lua` 文件获取完整配置示例。

## 更多信息

- audit.nvim 文档：[README.md](README.md)
- OpenCode 官方文档：https://github.com/NickvanDyke/opencode
- opencode.nvim 文档：https://github.com/NickvanDyke/opencode.nvim

---

**祝你审计愉快！🚀**
