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


[fzf]: https://github.com/junegunn/fzf
[fzf.vim]: https://github.com/junegunn/fzf.vim
[bookmark]: https://github.com/MattesGroeger/vim-bookmarks
[modes]: https://gist.github.com/kennypete/1fae2e48f5b0577f9b7b10712cec3212
