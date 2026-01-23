# Android Java 项目审计配置指南

本指南帮助你配置 audit.nvim 来审计 Android Java/Kotlin 项目。

## 目录

- [快速开始](#快速开始)
- [安装 Java LSP 服务器](#安装-java-lsp-服务器)
- [配置示例](#配置示例)
- [使用流程](#使用流程)
- [故障排除](#故障排除)

## 快速开始

### 1. 安装 Java LSP 服务器

#### 方法 A：使用 Mason.nvim（最简单）

在 Neovim 中：

```vim
" 1. 安装 mason.nvim（如果还没有）
:Lazy

" 2. 打开 Mason
:Mason

" 3. 搜索并安装 jdtls
/jdtls
按 i 安装

" 4. 可选：安装 Kotlin LSP
/kotlin
按 i 安装 kotlin-language-server
```

#### 方法 B：手动安装 jdtls

**macOS/Linux:**

```bash
# 1. 下载 jdtls
cd ~/.local/share/nvim
mkdir -p lsp
cd lsp

# 下载最新版本
wget https://www.eclipse.org/downloads/download.php?file=/jdtls/snapshots/jdt-language-server-latest.tar.gz -O jdtls.tar.gz

# 解压
mkdir jdtls
tar -xzf jdtls.tar.gz -C jdtls

# 2. 创建启动脚本
cat > ~/.local/bin/jdtls << 'EOF'
#!/bin/bash
JDTLS_HOME="$HOME/.local/share/nvim/lsp/jdtls"
JAR="$JDTLS_HOME/plugins/org.eclipse.equinox.launcher_*.jar"
CONFIG="$JDTLS_HOME/config_mac"  # Linux 使用 config_linux

java \
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \
  -Dosgi.bundles.defaultStartLevel=4 \
  -Declipse.product=org.eclipse.jdt.ls.core.product \
  -Dlog.protocol=true \
  -Dlog.level=ALL \
  -Xmx1G \
  --add-modules=ALL-SYSTEM \
  --add-opens java.base/java.util=ALL-UNNAMED \
  --add-opens java.base/java.lang=ALL-UNNAMED \
  -jar $(echo $JAR) \
  -configuration "$CONFIG" \
  "$@"
EOF

chmod +x ~/.local/bin/jdtls

# 3. 验证安装
jdtls --version
```

### 2. 安装 Mason.nvim（推荐）

Mason 可以帮助管理 LSP 服务器。添加到插件配置：

```lua
-- ~/.config/nvim/lua/plugins/mason.lua
return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'jdtls' },  -- 自动安装 jdtls
      })
    end,
  },
}
```

### 3. 更新插件配置

插件配置已经包含了 Java/Kotlin 支持，重新加载即可：

```vim
:Lazy sync
```

## 配置 Android 项目

### 创建项目特定的配置

在你的 Android 项目根目录创建配置文件：

#### 1. 创建 jdtls 配置

```bash
cd /path/to/your/android/project

cat > .jdtls.lua << 'EOF'
-- jdtls 项目配置
return {
  settings = {
    java = {
      -- Android SDK 路径
      home = vim.env.JAVA_HOME or '/usr/lib/jvm/java-11-openjdk',

      -- Android 项目配置
      configuration = {
        runtimes = {
          {
            name = "JavaSE-11",
            path = vim.env.JAVA_HOME or '/usr/lib/jvm/java-11-openjdk',
          },
        },
      },

      -- 代码格式化
      format = {
        enabled = true,
        settings = {
          url = vim.fn.expand("~/.config/nvim/formatter/java-google-style.xml"),
          profile = "GoogleStyle",
        },
      },

      -- 导入优化
      import = {
        gradle = { enabled = true },
        maven = { enabled = true },
        exclusions = {
          "**/build/**",
          "**/target/**",
          "**/.gradle/**",
        },
      },

      -- 补全设置
      completion = {
        favoriteStaticMembers = {
          "org.junit.Assert.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
        },
      },
    },
  },
}
EOF
```

#### 2. 配置 Gradle wrapper

确保项目有 Gradle wrapper：

```bash
# 检查是否有 gradlew
ls -la gradlew

# 如果没有，在项目根目录创建
gradle wrapper
```

#### 3. 生成 Android SDK 路径配置

```bash
# 设置 ANDROID_HOME 环境变量
echo "export ANDROID_HOME=$HOME/Library/Android/sdk" >> ~/.zshrc  # macOS
# 或
echo "export ANDROID_HOME=$HOME/Android/Sdk" >> ~/.bashrc  # Linux

source ~/.zshrc  # 或 source ~/.bashrc
```

### 4. 索引 Android 项目

```bash
# 索引项目（只索引 Java/Kotlin 源文件）
avim.py make -t /path/to/your/android/project

# 排除 build 目录（推荐）
avim.py make -t -e build .gradle /path/to/your/android/project

# 查看索引信息
avim.py info

# 打开项目
avim.py open /path/to/your/android/project
```

## LSP 功能配置

### 自动导入

在 Java 文件中：

```vim
" 自动添加缺失的导入
<Space>ca  " 代码操作，选择 "Add import"

" 组织导入
<Space>oi  " 需要配置快捷键（见下面）
```

添加额外的 Java 快捷键到 `plugin/audit.vim`：

```vim
" Java 特定快捷键 --- {{{
augroup JavaKeymap
  autocmd!
  autocmd FileType java nnoremap <buffer> <leader>oi <cmd>lua vim.lsp.buf.code_action({context = {only = {'source.organizeImports'}}, apply = true})<CR>
  autocmd FileType java nnoremap <buffer> <leader>tc <cmd>lua require('jdtls').test_class()<CR>
  autocmd FileType java nnoremap <buffer> <leader>tm <cmd>lua require('jdtls').test_nearest_method()<CR>
augroup END
" }}}
```

### Android 特定配置

对于 Android 项目，建议在 `local.properties` 中配置 SDK 路径：

```properties
# local.properties
sdk.dir=/Users/yourname/Library/Android/sdk
ndk.dir=/Users/yourname/Library/Android/sdk/ndk/25.1.8937393
```

## ctags 配置（支持 Java）

创建项目的 `.ctags` 文件：

```bash
cd /path/to/your/android/project

cat > .ctags << 'EOF'
# Java/Android ctags 配置

--languages=Java,Kotlin
--recurse=yes

# Java 特定选项
--java-kinds=+l
--java-kinds=+p
--fields=+iaS
--extra=+q

# Kotlin 支持（如果 ctags 支持）
--langdef=Kotlin
--langmap=Kotlin:.kt.kts
--regex-Kotlin=/^[ \t]*((abstract|final|sealed|implicit|lazy)[ \t]*)*(private[^ ]*|protected)?[ \t]*class[ \t]+([A-Za-z0-9_]+)/\4/c,classes/
--regex-Kotlin=/^[ \t]*((abstract|final|sealed|implicit|lazy)[ \t]*)*(private[^ ]*|protected)?[ \t]*object[ \t]+([A-Za-z0-9_]+)/\4/o,objects/
--regex-Kotlin=/^[ \t]*((abstract|final|sealed|implicit|lazy)[ \t]*)*(private[^ ]*|protected)?[ \t]*((abstract|final|sealed|implicit|lazy)[ \t]*)*data class[ \t]+([A-Za-z0-9_]+)/\6/d,data classes/
--regex-Kotlin=/^[ \t]*((abstract|final|sealed|implicit|lazy)[ \t]*)*(private[^ ]*|protected)?[ \t]*interface[ \t]+([A-Za-z0-9_]+)/\4/i,interfaces/
--regex-Kotlin=/^[ \t]*((abstract|final|sealed|implicit|lazy)[ \t]*)*(private[^ ]*|protected)?[ \t]*fun[ \t]+([A-Za-z0-9_]+)/\4/f,functions/

# 排除目录
--exclude=.git
--exclude=.gradle
--exclude=build
--exclude=.idea
--exclude=*.class
--exclude=*.jar
--exclude=*.apk
--exclude=*.dex
EOF
```

## 使用流程

### 完整的 Android 项目审计流程

```bash
# 1. 进入 Android 项目目录
cd /path/to/your/android/project

# 2. 创建配置（可选）
cat > .clangd << 'EOF'
# Android 项目可以不需要 .clangd
# 因为使用的是 Java LSP (jdtls)
EOF

# 3. 索引项目（排除 build 和 gradle 缓存目录）
avim.py make -t -e build .gradle .idea -f /path/to/your/android/project

# 4. 打开项目
avim.py open /path/to/your/android/project

# 5. 在 Neovim 中
# - 等待 jdtls 启动（首次可能需要 30 秒）
# - 查看状态: :LspInfo
# - 开始审计代码
```

### Gradle 项目结构识别

jdtls 会自动识别以下 Gradle 项目结构：

```
android-project/
├── app/
│   ├── build.gradle          # jdtls 识别为模块
│   └── src/
│       └── main/
│           └── java/         # 源代码
│               └── com/
│                   └── example/
├── build.gradle              # 根项目配置
├── settings.gradle           # 项目设置
└── gradlew                   # Gradle wrapper
```

## 实用快捷键（Java 项目）

在 Java 文件中：

```vim
" LSP 导航
<Space>fg  " 跳转到定义
<Space>fs  " 查找引用
<Space>fi  " 跳转到实现
<Space>ft  " 跳转到类型定义

" 重构
<Space>rn  " 重命名
<Space>ca  " 代码操作（修复导入、生成方法等）

" 搜索
F2         " ripgrep 搜索当前单词
<Space>ff  " FZF 文件搜索

" 符号大纲
<Space>o   " 显示类的方法和字段

" 诊断
[d         " 上一个错误
]d         " 下一个错误
<Space>di  " 显示错误详情
```

## 安装 Mason.nvim（推荐）

Mason 让 LSP 服务器管理变得简单：

```lua
-- ~/.config/nvim/lua/plugins/mason.lua
return {
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'jdtls',           -- Java
          'kotlin_language_server',  -- Kotlin
        },
        automatic_installation = true,
      })
    end,
  },
}
```

重启 Neovim，Mason 会自动安装 jdtls。

## 常见 Android 项目配置

### 配置 1：纯 Java Android 项目

```bash
cd /path/to/android/project

# 索引项目
avim.py make -t -e build .gradle .idea app/build

# 打开项目
avim.py open app/src/main/java/com/example/MainActivity.java
```

### 配置 2：Java + Kotlin 混合项目

```bash
# 确保 suffixes.txt 包含 .kt 文件（已添加）

# 索引
avim.py make -t -e build .gradle

# 打开
avim.py open .
```

### 配置 3：多模块 Android 项目

```bash
# 索引整个项目
cd /path/to/android/multi-module-project
avim.py make -t -e build .gradle .idea

# jdtls 会自动识别所有模块：
# - app/
# - library/
# - feature-module/
```

## Gradle 集成

### 自动同步 Gradle

jdtls 会自动检测 Gradle 项目并同步依赖。首次打开项目时：

1. jdtls 启动（状态栏显示 "jdtls"）
2. 自动执行 `gradle dependencies` 分析依赖
3. 索引所有依赖的 JAR 文件
4. 完成后可以跳转到 Android SDK 和第三方库

**注意：** 首次同步可能需要几分钟，请耐心等待。

### 手动触发 Gradle 同步

如果需要手动同步：

```vim
" 在 Neovim 中
:lua vim.lsp.buf.execute_command({command = 'java.projectConfiguration.update', arguments = {vim.uri_from_fname(vim.fn.expand('%'))}})
```

## Android SDK 配置

### 设置 ANDROID_HOME

```bash
# macOS
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools

# Linux
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools

# 添加到 ~/.zshrc 或 ~/.bashrc
```

### 配置 Java 版本

Android 项目通常需要特定的 Java 版本：

```bash
# 检查 Java 版本
java -version

# Android 建议使用 Java 11 或 17
# macOS 使用 brew
brew install openjdk@11
brew install openjdk@17

# 设置 JAVA_HOME
export JAVA_HOME=/usr/local/opt/openjdk@11
```

## 验证配置

### 1. 检查 jdtls 是否可用

```bash
# 检查命令是否存在
which jdtls

# 或使用 Mason
nvim +"Mason" +qa
```

### 2. 测试 LSP 功能

```bash
# 打开一个 Java 文件
avim.py open /path/to/android/project

# 在 Neovim 中
:e app/src/main/java/com/example/MainActivity.java
```

检查 LSP 状态：

```vim
" 1. 查看 LSP 信息
:LspInfo
" 应该看到: Client: jdtls (id: 1, bufnr: [1])

" 2. 测试跳转
" 光标放在一个类名上，按 <Space>fg
" 应该能跳转到定义

" 3. 测试查找引用
" 光标放在一个方法上，按 <Space>fs
" 应该列出所有调用位置

" 4. 查看符号大纲
<Space>o
" 应该显示类的所有方法和字段
```

### 3. 测试 Android 特定功能

```vim
" 打开 Activity 文件
:e app/src/main/java/com/example/MainActivity.java

" 测试跳转到 Android 框架类
" 光标放在 AppCompatActivity 上
<Space>fg  " 应该能跳转到 Android SDK 源码

" 测试自动导入
" 输入一个未导入的类名，如 TextView
<Space>ca  " 代码操作，选择 "Add import android.widget.TextView"
```

## 性能优化

### 排除不需要的目录

```bash
# 索引时排除这些目录可以大幅提升性能
avim.py make -t -e \
  build \
  .gradle \
  .idea \
  app/build \
  */build \
  .externalNativeBuild \
  /path/to/android/project
```

### 限制 jdtls 内存使用

编辑 jdtls 启动脚本，调整内存：

```bash
# 在 ~/.local/bin/jdtls 中
-Xmx2G   # 最大堆内存 2GB（默认 1GB）
-Xms512M # 初始堆内存 512MB
```

## 故障排除

### 问题 1：jdtls 启动失败

**症状：** `:LspInfo` 显示 jdtls 未附加

**解决：**
```vim
" 查看日志
:LspLog

" 或查看文件
:!tail -50 ~/.local/state/nvim/lsp.log | grep jdtls
```

**常见原因：**
- Java 版本不匹配（需要 Java 11+）
- ANDROID_HOME 未设置
- Gradle 配置错误

### 问题 2：找不到 Android SDK 类

**症状：** 无法跳转到 `Activity`、`View` 等 Android 框架类

**解决：**
1. 确保 ANDROID_HOME 已设置
2. 打开 `build.gradle` 检查 compileSdkVersion
3. 等待 jdtls 完成索引（首次可能需要 5-10 分钟）
4. 重启 LSP: `:LspRestart`

### 问题 3：Gradle 同步失败

**症状：** jdtls 无法识别依赖

**解决：**
```bash
# 在项目根目录手动运行 Gradle
./gradlew build --refresh-dependencies

# 清理缓存
./gradlew clean

# 重新索引
avim.py make -t -f .
```

### 问题 4：符号查找很慢

**症状：** `<Space>fs` 等操作很慢

**解决：**
1. 排除不需要的目录（build, .gradle）
2. 使用增量索引
3. 配置 `.gitignore` 排除不必要的文件

## 推荐的项目结构

```
android-project/
├── .clangd              # C/C++ 配置（如果有 JNI）
├── .ctags               # ctags 配置
├── .jdtls.lua           # jdtls 配置
├── build.gradle         # 根项目配置
├── settings.gradle      # 模块设置
├── gradlew              # Gradle wrapper
├── app/
│   ├── build.gradle
│   └── src/
│       └── main/
│           ├── java/    # Java 源码
│           ├── kotlin/  # Kotlin 源码（可选）
│           └── res/     # 资源文件
└── library/             # 库模块（可选）
```

## 高级功能

### 1. 使用 nvim-jdtls 插件（可选）

如果需要更高级的 Java 功能：

```lua
-- ~/.config/nvim/lua/plugins/jdtls.lua
return {
  {
    'mfussenegger/nvim-jdtls',
    ft = 'java',
    config = function()
      local config = {
        cmd = { 'jdtls' },
        root_dir = require('jdtls.setup').find_root({'gradlew', 'build.gradle', '.git'}),
        settings = {
          java = {
            signatureHelp = { enabled = true },
            contentProvider = { preferred = 'fernflower' },
          },
        },
      }
      require('jdtls').start_or_attach(config)
    end,
  },
}
```

### 2. 调试 Android 应用（可选）

安装 nvim-dap 和 java-debug：

```vim
:Mason
" 搜索并安装 java-debug-adapter
```

### 3. 测试运行（可选）

使用 nvim-jdtls 的测试功能：

```vim
" 运行当前测试类
<leader>tc

" 运行光标下的测试方法
<leader>tm
```

## 参考资料

- jdtls 文档: https://github.com/eclipse/eclipse.jdt.ls
- Android 开发文档: https://developer.android.com
- nvim-jdtls: https://github.com/mfussenegger/nvim-jdtls
- Mason: https://github.com/williamboman/mason.nvim

---

需要更多帮助？查看 `CLANG_CONFIG.md` 或运行 `./check_plugins.sh`
