# audit.nvim 快速部署指南

在新设备上快速部署 audit.nvim 的完整指南。

## 📦 方法 1: 一键部署（推荐）

### 步骤 1: 克隆项目

```bash
# 克隆到你喜欢的位置
git clone https://github.com/your-username/audit.vim.git ~/tools/audit.vim
cd ~/tools/audit.vim
```

### 步骤 2: 运行自动配置脚本

```bash
./scripts/generate_config.sh
```

脚本会自动：
- ✅ 检测项目路径
- ✅ 生成可移植的 Neovim 配置
- ✅ 自动检测 Mason LSP 路径
- ✅ （可选）设置环境变量

### 步骤 3: 安装 Python 依赖

```bash
python3 -m pip install -U rich
```

### 步骤 4: 启动 Neovim

```bash
nvim
```

第一次启动时，lazy.nvim 会自动安装所有插件。

完成！✅

---

## 📋 方法 2: 手动部署

适用于需要自定义配置的场景。

### 1. 环境准备

#### macOS
```bash
brew install universal-ctags ripgrep fzf neovim python3
python3 -m pip install rich
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt install universal-ctags ripgrep fzf neovim python3-pip
python3 -m pip install rich
```

### 2. 克隆项目

```bash
git clone https://github.com/your-username/audit.vim.git ~/tools/audit.vim
```

### 3. 设置环境变量

添加到 `~/.zshrc` 或 `~/.bashrc`:

```bash
export AUDIT_VIM_PATH="$HOME/tools/audit.vim"
```

然后：
```bash
source ~/.zshrc  # 或 source ~/.bashrc
```

### 4. 配置 Neovim

#### 方法 A: 使用生成脚本
```bash
cd ~/tools/audit.vim
./scripts/generate_config.sh
```

#### 方法 B: 手动复制配置
```bash
# 复制示例配置
cp ~/tools/audit.vim/example_config.lua ~/.config/nvim/lua/plugins/audit.lua

# 编辑配置，修改项目路径
nvim ~/.config/nvim/lua/plugins/audit.lua
```

修改这一行：
```lua
dir = '/Users/zs/tools/audit.vim',  -- 改为你的路径
```

为：
```lua
dir = vim.env.AUDIT_VIM_PATH or vim.fn.expand('~/tools/audit.vim'),
```

### 5. 安装 LSP 服务器（可选）

根据需要安装：

```vim
" 打开 Neovim
nvim

" 安装 Mason（LSP 管理器）
:Lazy sync

" 安装 LSP 服务器
:Mason

" 在 Mason 界面中，按 i 安装需要的 LSP：
" - jdtls (Java)
" - kotlin-language-server (Kotlin)
" - clangd (C/C++)
" - pyright (Python)
" 等等
```

---

## 🚀 方法 3: 在多台设备间同步

### 初始设置（第一台设备）

```bash
# 1. 生成配置
cd ~/tools/audit.vim
./scripts/generate_config.sh

# 2. 备份配置到云端（可选）
# 将生成的配置提交到你的 dotfiles 仓库
```

### 部署到新设备

```bash
# 1. 克隆项目
git clone https://github.com/your-username/audit.vim.git ~/tools/audit.vim

# 2. 如果你有 dotfiles 仓库，直接同步
# 否则，运行生成脚本
cd ~/tools/audit.vim
./scripts/generate_config.sh

# 3. 设置环境变量
echo 'export AUDIT_VIM_PATH="$HOME/tools/audit.vim"' >> ~/.zshrc
source ~/.zshrc

# 4. 启动 Neovim
nvim
```

---

## 🔧 配置验证

部署完成后，验证配置：

```bash
# 1. 检查插件
cd ~/tools/audit.vim
./scripts/check_plugins.sh

# 2. 在 Neovim 中检查
nvim
```

在 Neovim 中运行：
```vim
:checkhealth audit
:LspInfo
:Lazy
```

---

## 📝 使用示例

### 索引项目

```bash
# 索引一个 C/C++ 项目
cd ~/tools/audit.vim
./avim.py make -t /path/to/your/project

# 索引 Java/Android 项目（排除 build 目录）
./avim.py make -t -e build .gradle /path/to/android/project

# 查看所有已索引项目
./avim.py info

# 打开项目
./avim.py open /path/to/your/project
```

### LSP 功能测试

在 Neovim 中打开一个源文件：

```vim
" 查看 LSP 状态
:LspInfo

" 测试跳转（光标放在函数/类名上）
<Space>fg  " 跳转到定义
<Space>fs  " 查找引用
<Space>h   " 显示文档

" 符号大纲
<Space>o

" 全局搜索
F2  " 搜索当前单词
```

---

## 🐛 故障排除

### 问题 1: 找不到 audit.vim

**错误**: `Could not find audit.vim plugin`

**解决**:
```bash
# 检查环境变量
echo $AUDIT_VIM_PATH

# 如果为空，设置它
export AUDIT_VIM_PATH="$HOME/tools/audit.vim"

# 或重新运行配置脚本
cd ~/tools/audit.vim
./scripts/generate_config.sh
```

### 问题 2: LSP 无法启动

**错误**: `Client jdtls quit with exit code 13`

**解决**:
```bash
# 清理 LSP workspace
rm -rf ~/.local/share/nvim/jdtls-workspace/*

# 在 Neovim 中重启 LSP
:LspRestart
```

### 问题 3: Python 脚本报错

**错误**: `ModuleNotFoundError: No module named 'rich'`

**解决**:
```bash
python3 -m pip install -U rich
```

### 问题 4: 大文件 LSP 被禁用

**错误**: `lsp (not supported) [File exceeds disable_max_lines size]`

**解决**: 配置已包含 `disable_max_lines = nil`，如果仍有问题：
```bash
# 重新生成配置
cd ~/tools/audit.vim
./scripts/generate_config.sh
```

---

## 📚 进阶配置

### 自定义 LSP 设置

编辑 `~/.config/nvim/lua/plugins/audit.lua`，在对应的 LSP 配置中添加：

```lua
vim.lsp.config.jdtls = {
  cmd = { jdtls_cmd, '-data', workspace_dir },
  -- 添加自定义设置
  settings = {
    java = {
      format = {
        enabled = true,
        settings = {
          url = "path/to/your/style.xml",
        },
      },
    },
  },
}
```

### 添加更多 LSP

参考 example_config.lua 中的示例，添加其他语言的 LSP 支持。

---

## 🔗 相关文档

- [完整安装指南](docs/INSTALL.md)
- [Android 项目配置](docs/ANDROID_SETUP.md)
- [故障排除](TROUBLESHOOTING.md)
- [配置示例](example_config.lua)

---

## ⚡ 快速命令参考

```bash
# 项目管理
./avim.py make -t <project>     # 索引项目
./avim.py info                   # 列出所有项目
./avim.py open <project>         # 打开项目
./avim.py rm <project>           # 删除索引

# 配置管理
./scripts/generate_config.sh     # 生成配置
./scripts/check_plugins.sh       # 检查插件

# Java 项目特殊命令
./scripts/install_java_lsp.sh    # 安装 Java LSP
rm -rf ~/.local/share/nvim/jdtls-workspace/*  # 清理 Java LSP workspace
```

---

## 💡 提示

1. **第一次启动较慢**: Neovim 需要下载和安装插件，请耐心等待
2. **Java LSP 首次启动慢**: jdtls 需要索引项目，首次可能需要 1-2 分钟
3. **使用环境变量**: 设置 `AUDIT_VIM_PATH` 可以让配置更加灵活
4. **定期更新**: `cd ~/tools/audit.vim && git pull` 获取最新功能
5. **备份配置**: 建议将 `~/.config/nvim/lua/plugins/audit.lua` 加入你的 dotfiles

---

需要帮助？查看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md) 或提交 issue。
