# macOS 使用注意事项

## BSD vs GNU 工具

macOS 默认使用 BSD 版本的命令行工具，与 Linux 的 GNU 工具有一些差异。

### 已修复的兼容性问题

#### ✅ grep -P 问题

**问题：** BSD grep 不支持 `-P` (Perl 正则) 选项

**错误信息：**
```
grep: invalid option -- P
```

**解决方案：** 所有脚本已更新为使用 `-E`（扩展正则）或 `sed` 替代。

**示例修复：**
```bash
# 旧的（不兼容 macOS）
grep -oP 'version "?\K[0-9]+'

# 新的（兼容 macOS）
grep -o 'version "[0-9.]*"' | sed 's/version "//;s/\..*$//'
```

### 可选：安装 GNU 工具

如果你需要 GNU 版本的工具（完全兼容 Linux）：

```bash
# 安装 GNU 工具集
brew install coreutils findutils gnu-sed gnu-grep gawk

# 使用 g 前缀调用
ggrep -P 'pattern' file    # GNU grep
gsed 's/old/new/' file      # GNU sed
gfind . -name '*.c'         # GNU find
gawk '{print $1}' file      # GNU awk

# 或者将 GNU 工具设为默认（不推荐，可能影响系统）
# 在 ~/.zshrc 中添加：
# export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
# export PATH="/usr/local/opt/findutils/libexec/gnubin:$PATH"
# export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
# export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
```

## macOS 特定配置

### Homebrew 路径

macOS 上 Homebrew 的安装路径：

**Intel Mac (x86_64):**
```bash
/usr/local/bin/
/usr/local/opt/
```

**Apple Silicon (ARM):**
```bash
/opt/homebrew/bin/
/opt/homebrew/opt/
```

### Java 安装位置

**通过 Homebrew 安装：**
```bash
brew install openjdk@11

# 设置 JAVA_HOME
export JAVA_HOME=/usr/local/opt/openjdk@11  # Intel
# 或
export JAVA_HOME=/opt/homebrew/opt/openjdk@11  # ARM

# 添加到 PATH
export PATH="$JAVA_HOME/bin:$PATH"
```

**验证：**
```bash
java -version
echo $JAVA_HOME
```

### Android SDK 位置

macOS 上 Android Studio 默认安装路径：

```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
```

### Neovim 配置位置

```bash
# 配置目录
~/.config/nvim/

# 数据目录
~/.local/share/nvim/

# 状态目录
~/.local/state/nvim/

# 缓存目录
~/.cache/nvim/
```

## macOS 常见问题

### 问题 1：命令找不到

**症状：** `command not found: avim.py`

**解决：**
```bash
# 确保 ~/.local/bin 在 PATH 中
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 验证
which avim.py
echo $PATH | grep ".local/bin"
```

### 问题 2：符号链接权限

**症状：** `Operation not permitted` 创建符号链接时

**解决：**
```bash
# macOS Catalina+ 可能有权限限制
# 方法 1：使用 sudo
sudo ln -sf source target

# 方法 2：给予终端完全磁盘访问权限
# 系统偏好设置 > 安全性与隐私 > 完全磁盘访问权限 > 添加终端
```

### 问题 3：ctags 版本问题

**症状：** `ctags: illegal option`

**解决：**
```bash
# macOS 自带的是 BSD ctags，需要安装 Universal Ctags
brew install universal-ctags

# 验证
ctags --version | head -1
# 应该显示: Universal Ctags

# 如果还是显示 BSD ctags，检查 PATH
which ctags
# 应该是: /usr/local/bin/ctags 或 /opt/homebrew/bin/ctags
```

### 问题 4：Python 路径

**症状：** `python3: command not found`

**解决：**
```bash
# 安装 Python 3
brew install python3

# 或使用系统自带的 Python 3
which python3
# macOS Monterey+ 自带 Python 3

# 验证
python3 --version
```

### 问题 5：clangd 路径

**症状：** clangd 无法找到系统头文件

**解决：**
```bash
# 通过 Homebrew 安装 LLVM
brew install llvm

# 添加到 PATH
export PATH="/usr/local/opt/llvm/bin:$PATH"  # Intel
# 或
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"  # ARM

# 验证
which clangd
clangd --version
```

## macOS 推荐配置

### ~/.zshrc 配置示例

```bash
# audit.nvim 相关环境变量

# PATH
export PATH="$HOME/.local/bin:$PATH"

# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Java
export JAVA_HOME=$(/usr/libexec/java_home -v 11)  # 自动找到 Java 11
export PATH="$JAVA_HOME/bin:$PATH"

# Android SDK
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools

# LLVM/clangd (如果通过 brew 安装)
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# GNU 工具（可选，如果安装了）
# export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
```

重新加载配置：
```bash
source ~/.zshrc
```

## 脚本兼容性检查

所有 audit.nvim 脚本已经过 macOS 兼容性测试：

| 脚本 | macOS 兼容 | 说明 |
|------|-----------|------|
| `install.sh` | ✅ | 使用 `grep -E` 而不是 `-P` |
| `install_java_lsp.sh` | ✅ | 已修复 grep -P 问题 |
| `setup_clangd.sh` | ✅ | 使用兼容的正则语法 |
| `check_plugins.sh` | ✅ | 纯 bash，无 GNU 依赖 |
| `setup_config.sh` | ✅ | 纯 bash |

## 验证 macOS 兼容性

### 测试所有脚本

```bash
cd /Users/zs/tools/audit.vim

# 语法检查
for script in *.sh; do
    echo "检查: $script"
    bash -n "$script" && echo "✓ $script 语法正确"
done

# 实际运行测试（dry run）
./check_plugins.sh
```

### 测试 Java 版本检测

```bash
# 应该正确显示 Java 版本
java -version 2>&1 | grep -o 'version "[0-9.]*"' | head -1 | sed 's/version "//;s/\..*$//'
```

## 快速修复命令

如果遇到 `grep: invalid option` 错误：

```bash
# 1. 检查是否使用了 -P 选项
grep -n "grep.*-P" problematic_script.sh

# 2. 替换为兼容的语法
# -P '\K'         → sed 或 awk
# -P '(?=pattern)' → grep -E 简化的正则
# -P '(?<=pattern)' → sed 或 awk

# 3. 或安装 GNU grep
brew install grep
# 使用 ggrep 命令
```

## 推荐的 macOS 开发环境

### 必装工具

```bash
# 1. Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. 基础开发工具
brew install git neovim python@3.11

# 3. audit.nvim 依赖
brew install universal-ctags ripgrep fzf

# 4. 编译工具链
brew install llvm cmake ninja

# 5. Java 开发（如果需要）
brew install openjdk@11

# 6. Android 开发（如果需要）
brew install --cask android-studio
```

### 开发工具版本确认

```bash
nvim --version | head -1
python3 --version
java -version
ctags --version | head -1
rg --version | head -1
fzf --version
clangd --version
```

所有命令都应该能正常运行并显示版本号。

## 获取帮助

如果在 macOS 上遇到其他兼容性问题：

1. 查看错误信息中的具体命令
2. 检查是否使用了 GNU 特定的选项
3. 参考本文档的兼容性说明
4. 或提交 Issue 报告问题

---

所有脚本已针对 macOS 进行优化和测试。
