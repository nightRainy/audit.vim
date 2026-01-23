# Audit.NVIM

轻量级代码审计（代码审查）工具，基于 Neovim。

![audit.nvim](https://img-blog.csdnimg.cn/direct/10717e760e96410b93c1cf02269f8c56.png)

**包含:**
- Python 包装脚本
- Neovim 插件

**⚠️ 重要变更:** 此版本仅支持 **Neovim 0.5+**。如果您使用 Vim，请使用旧版本。

## 支持的项目类型

audit.nvim 支持审计以下类型的项目：

- ✅ **C/C++ 项目** - 使用 clangd LSP
- ✅ **Python 项目** - 使用 pyright LSP
- ✅ **Rust 项目** - 使用 rust-analyzer LSP
- ✅ **Go 项目** - 使用 gopls LSP
- ✅ **Java/Android 项目** - 使用 jdtls LSP（支持 Gradle）
- ✅ **Kotlin/Android 项目** - 使用 kotlin-language-server
- ✅ **JavaScript/TypeScript 项目** - 使用 ts_ls LSP

# 安装

## 依赖

**必需插件:**
- [stevearc/aerial.nvim](https://github.com/stevearc/aerial.nvim) - 符号大纲查看器
- [skywind3000/asyncrun.vim](https://github.com/skywind3000/asyncrun.vim) - 异步运行 shell 命令
- [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP 配置（替代 cscope）

**推荐插件:**
- [junegunn/fzf][fzf] - `:FZF` 命令用于跨文件搜索和跳转
- [junegunn/fzf.vim][fzf.vim] - `:RG`, `:Files`, `:Buffers` 等命令
- [MattesGroeger/vim-bookmarks][bookmark] - 带注释的书签
- [NickvanDyke/opencode.nvim](https://github.com/NickvanDyke/opencode.nvim) - OpenCode AI 编程助手（可选）

**外部命令行工具:**
- [ctags](https://github.com/universal-ctags/ctags) - Universal Ctags
- [ripgrep](https://github.com/BurntSushi/ripgrep) - 快速搜索工具
- [fzf][fzf] - 模糊搜索

**⚠️ 不再需要 cscope**，已由 LSP 替代。

## 快速安装（推荐）

### 一键安装脚本

**macOS / Linux:**
```sh
# 克隆仓库
git clone https://github.com/your-repo/audit.nvim.git
cd audit.nvim

# 运行自动化安装脚本（会安装所有依赖和插件）
./install.sh
```

**Windows (PowerShell):**
```powershell
# 克隆仓库
git clone https://github.com/your-repo/audit.nvim.git
cd audit.nvim

# 以管理员权限运行
.\install.ps1
```

安装脚本会自动完成：
- ✅ 安装 Neovim (如果未安装)
- ✅ 安装外部工具 (ctags, ripgrep, fzf)
- ✅ 安装 Python 依赖 (rich)
- ✅ 安装 audit.nvim 插件
- ✅ 生成 Neovim 插件配置

## 手动安装

如果自动化脚本无法使用，可以手动安装：

```sh
# 1. 安装 Python 依赖
python3 -m pip install -U rich

# 2. 安装插件
make install
```

## 配置 Neovim

在你的 `~/.config/nvim/init.lua` 中添加:

```lua
-- 1. 安装插件（使用你喜欢的插件管理器，如 lazy.nvim, packer.nvim）

-- 2. 设置 aerial.nvim
require('aerial').setup({
  backends = { "lsp", "treesitter", "markdown" },
  layout = {
    default_direction = "left",
    width = 30,
  },
})

-- 3. 设置 LSP（示例：C/C++）
require('lspconfig').clangd.setup({
  on_attach = function(client, bufnr)
    -- audit.nvim LSP 快捷键已在 plugin/audit.vim 中定义
  end,
})

-- 4. （可选）加载 audit.lua 模块进行更高级的配置
-- local audit = require('audit')
-- audit.setup()

-- 5. （可选）配置 OpenCode AI 编程助手
-- 需要先安装 opencode.nvim 和 OpenCode CLI
-- 安装方法见下文"OpenCode AI 编程助手"章节
local opencode_config = require('audit.opencode')
if opencode_config.check_cli() then
  opencode_config.setup({
    -- 自定义快捷键（可选）
    keymaps = {
      ask = "<C-a>",      -- 询问 AI
      select = "<C-x>",   -- 选择动作
      toggle = "<C-.>",   -- 切换终端
    },
  })
  -- 设置内置命令
  opencode_config.setup_commands()
end
```

## macOS

```sh
brew install universal-ctags ripgrep fzf
brew install neovim  # 如果还没安装
```

## Linux

```sh
sudo apt install -y universal-ctags ripgrep fzf neovim
```

## 验证安装

安装完成后，运行插件检查脚本：

```sh
./check_plugins.sh
```

这会检查所有必需的插件是否已正确安装。如果有插件缺失，脚本会提供安装建议。

**常见问题：** 如果遇到 `E492: Not an editor command: AsyncRun!` 错误，请查看 [QUICKFIX.md](QUICKFIX.md) 获取解决方案。

# 使用

## 索引项目

```sh
$ avim.py make -h
usage: avim.py make [-h] [-t] [-f] [-e EXCLUDES [EXCLUDES ...]] [src]

positional arguments:
  src                   project root directory to make

options:
  -h, --help            show this help message and exit
  -t                    create tag
  -f                    force overwrite
  -e EXCLUDES [EXCLUDES ...]
                        exclude paths
```

示例（注意：移除了 -c 参数，不再需要 cscope）:
```sh
$ avim.py make -t /path/to/linux-1.11
```

## 列出已索引的项目

```sh
$ avim.py info
┏━━━━━━━━━━━┳━━━━━━━┳━━━━━━━━━┳━━━━━━━━━━┓
┃ location  ┃ files ┃ ctags   ┃ bookmark ┃
┡━━━━━━━━━━━╇━━━━━━━╇━━━━━━━━━╇━━━━━━━━━━┩
│ /src/foo  │ 46    │ 257.8KB │ 0        │
│ /src/bar  │ 852   │ 9.0MB   │ 2        │
│ /src/barz │ 10395 │ -       │ 5        │
└───────────┴───────┴─────────┴──────────┘
```

注意：cscope 列已移除。

## 删除索引

```sh
$ avim.py rm /path/to/linux-1.11
```

## 使用 Neovim 打开项目

```sh
# 打开当前目录
$ avim.py open .

# 打开指定项目
$ avim.py open /src/project

# 跳转到指定标签
$ avim.py open -t function_name
```

注意：移除了 `-g` (gvim) 参数，现在只使用 `nvim`。

## 处理 C 语言条件编译（#ifdef）

如果你的 C 项目包含很多 `#ifdef`、`#ifndef` 等条件编译，需要配置 clangd 来识别这些宏：

```bash
# 方法 1：使用自动化脚本
./setup_clangd.sh /path/to/your/project

# 方法 2：手动创建 .clangd 文件
cd /path/to/your/project
cat > .clangd << 'EOF'
CompileFlags:
  Add:
    - -DCONFIG_USB_DEBUG=1
    - -DCONFIG_USB_POWER=1
    - -DDEBUG=1
EOF

# 然后重新索引
avim.py make -t -f /path/to/your/project
```

详细配置说明请查看 [CLANG_CONFIG.md](CLANG_CONFIG.md)。

## 审计 Android/Java 项目

对于 Android Java 项目（Gradle 管理）：

```bash
# 1. 安装 Java LSP
./install_java_lsp.sh

# 2. 索引 Android 项目（排除 build 目录）
avim.py make -t -e build .gradle /path/to/android/project

# 3. 打开项目
avim.py open /path/to/android/project
```

详细配置请查看：
- **快速开始**: [ANDROID_QUICKSTART.md](ANDROID_QUICKSTART.md)
- **详细配置**: [ANDROID_SETUP.md](ANDROID_SETUP.md)

# Neovim 快捷键

audit.nvim 定义的快捷键:

## LSP 符号导航（替代 cscope）

```
<leader>fs - 查找符号引用（LSP references）
<leader>fg - 查找全局定义（LSP definition）
<leader>fc - 查找调用此函数的位置（LSP incoming calls）
<leader>ft - 查找类型定义（LSP type definition）
<leader>fe - 使用 ripgrep 搜索表达式
<leader>fd - 查找此函数调用的函数（LSP outgoing calls）

<leader>h - 显示悬停信息（LSP hover）
<leader>rn - 重命名符号（LSP rename）
<leader>ca - 代码操作（LSP code action）
<leader>di - 显示诊断信息
[d - 跳到上一个诊断
]d - 跳到下一个诊断
```

## 其他快捷键

```
<leader>o - 切换 aerial 符号大纲
<leader>q - 切换 quickfix 列表
<leader>ff - FZF 文件搜索

F2 - 使用 ripgrep 搜索当前单词或选中文本
F3 - 搜索方法定义

J/K - quickfix 列表上/下移动
i/o - 向上/向下移动（5 行）
u/d - 向上/向下滚动页面
a/s - 切换到上一个/下一个缓冲区
```

> 注意: `<leader>` 由用户配置，我的是 `,`。

## Mark

```
m{a-zA-Z}         Set mark {a-zA-Z} at cursor position.
'{a-z} `{a-z}     Jump to the mark {a-z} in the current buffer.
:marks            List all current marks.
:Marks            List marks with fzf search.
```

You can also use [vim-bookmarks][bookmark] plugin for better bookmarks support.

| Action                                          | Shortcut    | Command                      |
|-------------------------------------------------|-------------|------------------------------|
| Add/remove bookmark at current line             | `mm`        | `:BookmarkToggle`            |
| Add/edit/remove annotation at current line      | `mi`        | `:BookmarkAnnotate <TEXT>`   |
| Show all bookmarks (toggle)                     | `ma`        | `:BookmarkShowAll`           |
| Clear bookmarks in current buffer only          | `mc`        | `:BookmarkClear`             |
| Clear bookmarks in all buffers                  | `mx`        | `:BookmarkClearAll`          |
| Save all bookmarks to a file                    |             | `:BookmarkSave <FILE_PATH>`  |
| Load bookmarks from a file                      |             | `:BookmarkLoad <FILE_PATH>`  |

## Folding

```
za      toggle open/close fold
zd      delete fold
zf      create fold
zfi}    create fold inside `{}` (excluding)
zfa}    create fold inside `{}` (including)
```

## OpenCode AI 编程助手（可选）

audit.nvim 现已支持集成 [OpenCode AI](https://github.com/NickvanDyke/opencode) 编程助手，提供智能代码辅助、代码审查、自动优化等功能。

**📚 快速开始：** 参见 [OPENCODE_QUICKSTART.md](OPENCODE_QUICKSTART.md)

**📖 完整配置示例：** 参见 [example_config.lua](example_config.lua)

### 安装 OpenCode

**1. 安装 OpenCode CLI**

访问 [OpenCode 官方仓库](https://github.com/NickvanDyke/opencode) 安装 CLI 工具。

**2. 安装 opencode.nvim 插件**

使用 lazy.nvim：

```lua
{
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- 推荐用于 ask() 和 select()
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    -- 基础配置会由 audit.opencode 模块处理
  end,
}
```

**3. 在 init.lua 中配置**

```lua
-- 使用 audit.nvim 提供的 opencode 配置模块
local opencode_config = require('audit.opencode')

-- 检查 CLI 是否安装
if opencode_config.check_cli() then
  opencode_config.setup({
    -- 自定义快捷键（可选，默认如下）
    keymaps = {
      ask = "<C-a>",      -- 询问 AI
      select = "<C-x>",   -- 选择动作
      toggle = "<C-.>",   -- 切换终端
    },
    -- 额外的 opencode.nvim 配置（可选）
    opencode_opts = {
      -- 在 opencode.nvim 文档中查看更多配置选项
    },
  })

  -- 设置内置命令
  opencode_config.setup_commands()
else
  print("OpenCode CLI not found. Please install it first.")
end
```

### OpenCode 快捷键

默认快捷键：

```
<C-a>  - 询问 AI（普通模式和可视模式）
         自动包含 @this 上下文（当前选区或光标位置）
<C-x>  - 选择执行动作（提示词、命令等）
<C-.>  - 切换 opencode 终端（普通模式和终端模式）
```

### 内置命令

audit.nvim 为 opencode 提供了便捷的命令：

```vim
:OpencodeExplainDiagnostics  " 解释当前缓冲区的诊断信息
:OpencodeFix                 " 修复诊断问题
:OpencodeExplain             " 解释当前代码
:OpencodeReview              " 审查代码的正确性和可读性
:OpencodeOptimize            " 优化代码性能和可读性
:OpencodeDocument            " 为代码添加文档注释
:OpencodeTest                " 为代码添加测试
:OpencodeAsk [prompt]        " 自由提问
```

### 上下文占位符

OpenCode 支持在提示词中使用占位符来引用编辑器上下文：

- `@this` - 当前选区或光标位置
- `@buffer` - 当前缓冲区
- `@buffers` - 所有打开的缓冲区
- `@visible` - 可见文本
- `@diagnostics` - 当前缓冲区的诊断信息
- `@quickfix` - quickfix 列表
- `@diff` - Git diff
- `@marks` - 全局标记

### 使用示例

**1. 询问 AI 关于当前代码**

```vim
" 普通模式：询问光标所在位置的代码
<C-a>

" 可视模式：选中代码后询问
" 1. 进入可视模式选中代码（v 或 V）
" 2. 按 <C-a>
" 3. 输入问题，AI 会自动包含选中的代码上下文
```

**2. 代码审查**

```vim
" 审查当前函数
" 1. 将光标放在函数上
" 2. 运行命令
:OpencodeReview

" 或在可视模式选中代码后
:'<,'>OpencodeReview
```

**3. 修复诊断问题**

```vim
" 如果当前文件有 LSP 诊断错误
:OpencodeFix
```

**4. 优化代码**

```vim
" 选中代码后优化
" 1. 可视模式选中代码
" 2. 运行
:'<,'>OpencodeOptimize
```

**5. 查看状态**

```vim
" 查看 OpenCode 状态和可用命令
:lua require('audit.opencode').show_status()
```

**6. 启动 OpenCode 服务器**

```vim
" 在 Neovim 内置终端中启动 opencode 服务器
:lua require('audit.opencode').start_server()
```

### 高级配置

**自定义提示词**

你可以通过 `vim.g.opencode_opts` 添加自定义提示词：

```lua
vim.g.opencode_opts = {
  prompts = {
    -- 添加自定义提示词
    refactor = {
      template = "Refactor @this to improve code quality",
    },
    security = {
      template = "Check @this for security vulnerabilities",
    },
  },
}
```

**事件监听**

监听 OpenCode 事件：

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = "OpencodeEvent:*",
  callback = function(args)
    local event = args.data.event
    if event == "session.idle" then
      print("OpenCode 响应完成")
    end
  end,
})
```

### 注意事项

1. **端口配置**: OpenCode CLI 必须使用 `--port` 标志运行才能暴露服务器
2. **autoread 设置**: 插件会自动设置 `vim.o.autoread = true` 以支持实时重载
3. **依赖插件**: 推荐安装 `folke/snacks.nvim` 以获得最佳体验
4. **性能**: OpenCode 会自动连接到工作目录中运行的实例，或使用内置实例

### 快速开始

```bash
# 1. 安装 OpenCode CLI（参考官方文档）
# 2. 在 Neovim 中启动服务器
:lua require('audit.opencode').start_server()

# 3. 在代码中使用 <C-a> 开始提问
```


[fzf]: https://github.com/junegunn/fzf
[fzf.vim]: https://github.com/junegunn/fzf.vim
[bookmark]: https://github.com/MattesGroeger/vim-bookmarks
[modes]: https://gist.github.com/kennypete/1fae2e48f5b0577f9b7b10712cec3212
