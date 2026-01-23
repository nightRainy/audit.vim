# C/C++ 条件编译符号识别配置

## 问题说明

当 C 代码中包含 `#ifdef`、`#ifndef`、`#if defined()` 等条件编译时，某些符号可能无法被正确识别：

```c
#ifdef CONFIG_USB_DEBUG
void usb_debug_init(void) {  // 这个函数可能无法被识别
    // ...
}
#endif
```

## 解决方案

### 方案 1：使用 .clangd 配置文件（推荐）

在项目根目录创建 `.clangd` 文件，定义需要的宏：

#### 步骤 1：创建配置文件

```bash
cd /path/to/your/project
cat > .clangd << 'EOF'
CompileFlags:
  Add:
    # 定义常用的宏
    - -DCONFIG_USB_DEBUG=1
    - -DCONFIG_USB_POWER=1
    - -DDEBUG=1
    - -D__KERNEL__
    - -D__LINUX__

  # 移除可能导致问题的编译参数
  Remove:
    - -mabi=*
    - -march=*
    - -mcpu=*

# 诊断配置
Diagnostics:
  UnusedIncludes: None
  MissingIncludes: None

# 索引配置
Index:
  Background: Build
EOF
```

#### 步骤 2：重新索引

```bash
# 重新生成 tags
avim.py make -t -f /path/to/your/project

# 重启 Neovim
nvim /path/to/your/project
```

### 方案 2：使用 compile_commands.json（最准确）

这是最准确的方法，使用实际的编译参数。

#### 如果使用 CMake：

```bash
cd /path/to/your/project
mkdir build && cd build
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1 ..

# 复制到项目根目录
cp compile_commands.json ..
```

#### 如果使用 Make：

安装 Bear 工具：

```bash
# macOS
brew install bear

# Linux
sudo apt install bear
```

然后：

```bash
cd /path/to/your/project

# 清理并使用 bear 捕获编译命令
make clean
bear -- make

# 会生成 compile_commands.json
```

#### 如果使用内核 Makefile：

Linux 内核项目：

```bash
cd /path/to/linux/kernel

# 生成 compile_commands.json
make defconfig  # 或你的配置
scripts/clang-tools/gen_compile_commands.py
```

### 方案 3：配置 ctags 处理宏

创建 `.ctags` 配置文件：

```bash
cd /path/to/your/project
cat > .ctags << 'EOF'
# 定义宏，让 ctags 知道如何处理它们
-I __THROW
-I __attribute__+
-I __attribute__+=
-I __restrict
-I __extension__

# 定义条件编译宏（当作已定义）
-D CONFIG_USB_DEBUG=1
-D CONFIG_USB_POWER=1
-D DEBUG=1
-D __KERNEL__=1

# 递归扫描
--recurse=yes

# C/C++ 特定选项
--c-kinds=+p
--c++-kinds=+p
--fields=+iaS
--extra=+q

# 排除目录
--exclude=.git
--exclude=build
--exclude=*.o
EOF
```

然后重新生成 tags：

```bash
avim.py make -t -f /path/to/your/project
```

### 方案 4：全局 clangd 配置

如果你有多个项目都需要类似的配置，可以创建全局配置：

```bash
mkdir -p ~/.config/clangd
cat > ~/.config/clangd/config.yaml << 'EOF'
CompileFlags:
  Add:
    # 常用宏定义
    - -DDEBUG=1
    - -D__KERNEL__
    - -D__LINUX__

# 如果特定项目有不同配置，它会覆盖这个全局配置
EOF
```

## 项目特定配置示例

### Linux 内核项目

```yaml
# .clangd
CompileFlags:
  Add:
    - -D__KERNEL__
    - -DCONFIG_64BIT
    - -DCONFIG_SMP
    - -DCONFIG_DEBUG_KERNEL
    - -I/path/to/kernel/include
    - -I/path/to/kernel/arch/x86/include
  Remove:
    - -mabi=*
    - -march=*

Index:
  Background: Build
```

### U-Boot 项目

```yaml
# .clangd
CompileFlags:
  Add:
    - -D__UBOOT__
    - -DCONFIG_ARM
    - -DCONFIG_SYS_DEBUG
    - -I./include
    - -I./arch/arm/include
```

### 嵌入式项目

```yaml
# .clangd
CompileFlags:
  Add:
    - -DCONFIG_USB_DEBUG=1
    - -DCONFIG_USB_POWER=1
    - -DENABLE_TRACE=1
    - -D__ARM_ARCH=7
    - -I./include
    - -I./drivers/include
  Remove:
    - -mcpu=*
    - -mthumb
```

## 验证配置

### 1. 测试 clangd

```bash
# 打开一个 C 文件
nvim your_file.c

# 在 Neovim 中检查 LSP 状态
:LspInfo

# 应该看到 clangd 已附加，没有错误
```

### 2. 测试符号跳转

```vim
" 将光标放在被 #ifdef 包裹的函数上
" 按 <Space>fg 跳转到定义
" 应该能够正确跳转
```

### 3. 查看 clangd 日志

如果还有问题，查看 clangd 日志：

```vim
" 在 Neovim 中
:LspLog

" 或者查看日志文件
:!tail -f ~/.local/state/nvim/lsp.log
```

## 常见宏定义参考

### 通用调试宏

```yaml
- -DDEBUG=1
- -D_DEBUG=1
- -DNDEBUG=0
- -DENABLE_TRACE=1
- -DVERBOSE=1
```

### 平台相关宏

```yaml
# Linux
- -D__LINUX__
- -D__KERNEL__
- -DCONFIG_64BIT

# ARM
- -D__ARM__
- -D__ARM_ARCH=7

# x86
- -D__x86_64__
- -D__i386__
```

### 编译器相关宏

```yaml
- -D__GNUC__=11
- -D__clang__=1
- -D__STDC_VERSION__=201112L
```

## 自动化脚本

创建一个脚本来快速生成 `.clangd` 配置：

```bash
#!/bin/bash
# create_clangd_config.sh

cat > .clangd << 'EOF'
CompileFlags:
  Add:
EOF

# 从现有的 Makefile 或配置中提取宏定义
if [ -f "Makefile" ]; then
    echo "从 Makefile 提取宏定义..."
    grep -oP 'D[A-Z_]+' Makefile | sort -u | while read macro; do
        echo "    - -$macro=1" >> .clangd
    done
fi

# 添加常用的系统宏
cat >> .clangd << 'EOF'
    - -DDEBUG=1
    - -D__KERNEL__
  Remove:
    - -mabi=*
    - -march=*

Index:
  Background: Build
EOF

echo "✓ .clangd 配置已创建"
```

使用：

```bash
chmod +x create_clangd_config.sh
./create_clangd_config.sh
```

## 故障排除

### 问题 1：clangd 不识别宏

**检查：**
```vim
:LspInfo
```

**解决：**
1. 确保 `.clangd` 文件在项目根目录
2. 重启 LSP: `:LspRestart`
3. 重启 Neovim

### 问题 2：ctags 不识别宏

**检查：**
```bash
ctags --list-kinds=c
```

**解决：**
1. 确保 `.ctags` 文件存在
2. 重新生成 tags: `avim.py make -t -f .`
3. 使用 `-D` 参数定义宏

### 问题 3：太多误报错误

在 `.clangd` 中禁用某些诊断：

```yaml
Diagnostics:
  Suppress:
    - macro-redefined
    - unknown-warning-option
  UnusedIncludes: None
  MissingIncludes: None
```

## 推荐工作流

1. **首先尝试 compile_commands.json**（最准确）
2. **如果没有构建系统，使用 .clangd**（最方便）
3. **同时配置 .ctags**（作为补充）
4. **测试验证**（跳转、补全、诊断）

## 相关文档

- clangd 配置: https://clangd.llvm.org/config
- ctags 手册: `man ctags`
- compile_commands.json: https://clang.llvm.org/docs/JSONCompilationDatabase.html

---

需要更多帮助？运行 `:h lspconfig` 或查看 QUICKFIX.md
