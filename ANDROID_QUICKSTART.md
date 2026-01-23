# Android 项目快速开始

## 5 分钟快速配置

### 1. 安装 Java LSP（2 分钟）

```bash
cd /Users/zs/tools/audit.vim
./install_java_lsp.sh
# 选择 1（使用 Mason，推荐）
```

### 2. 重启 Neovim 并安装插件（2 分钟）

```bash
nvim
```

在 Neovim 中：
```vim
:Lazy sync    " 同步插件
:Mason        " 等待 jdtls 自动安装
```

等待 Mason 完成安装，显示：
```
✓ jdtls
```

按 `q` 退出，然后 `:qa` 重启 Neovim。

### 3. 索引 Android 项目（1 分钟）

```bash
# 索引你的 Android 项目
avim.py make -t -e build .gradle /path/to/your/android/project

# 打开项目
avim.py open /path/to/your/android/project
```

### 4. 测试功能

在 Neovim 中打开一个 Java 文件：

```vim
:e app/src/main/java/com/example/MainActivity.java

" 等待 jdtls 启动（状态栏显示 jdtls，首次需要 30-60 秒）

" 测试跳转
<Space>fg  " 光标放在 AppCompatActivity 上，应该能跳转

" 测试查找引用
<Space>fs  " 光标放在 onCreate 上，查找所有调用

" 测试符号大纲
<Space>o   " 显示类的所有方法

" 测试搜索
F2         " 搜索当前单词
```

## 完成！✅

现在你可以审计 Android Java 项目了！

## 常用操作速查

| 操作 | 快捷键 | 说明 |
|------|--------|------|
| 跳转到定义 | `<Space>fg` | 跳转到类/方法定义 |
| 查找引用 | `<Space>fs` | 查找所有使用位置 |
| 查找调用者 | `<Space>fc` | 谁调用了这个方法 |
| 符号大纲 | `<Space>o` | 显示类结构 |
| 搜索文本 | `F2` | ripgrep 全局搜索 |
| 文件搜索 | `<Space>ff` | FZF 文件名搜索 |
| 重命名 | `<Space>rn` | 重命名变量/方法 |
| 代码操作 | `<Space>ca` | 修复导入/生成代码 |
| 悬停文档 | `<Space>h` | 查看文档 |

## 项目管理

```bash
# 索引项目
avim.py make -t /path/to/project

# 列出所有项目
avim.py info

# 删除索引
avim.py rm /path/to/project

# 切换项目
avim.py open /path/to/another/project
```

## 故障排除

### jdtls 未启动

```vim
:LspInfo
" 查看 jdtls 状态

:LspLog
" 查看错误日志
```

### 找不到类定义

1. 等待 Gradle 同步完成
2. 检查 `:LspInfo` 确保 jdtls 已附加
3. 重启 LSP: `:LspRestart`

### 详细文档

查看 `ANDROID_SETUP.md` 获取完整配置说明。
