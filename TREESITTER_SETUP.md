# Tree-sitter 语法高亮设置指南

## 问题说明
Java 代码没有语法高亮，只有变量高亮。这是因为 Tree-sitter 的 Java parser 没有安装。

---

## 🚀 快速解决方案（推荐）

### 方法1：在 Neovim 内安装（最简单）

1. **启动 Neovim**：
```bash
nvim
```

2. **安装 Java parser**：
```vim
:TSInstall java
```

3. **等待安装完成**（会看到下载进度）

4. **重新打开 Java 文件**：
```vim
:e %
```

现在语法高亮应该正常工作了！

---

### 方法2：安装多个语言（推荐用于代码审计）

如果你需要审计多种语言的代码，一次性安装所有常用 parsers：

```vim
:TSInstall java kotlin c cpp python javascript typescript lua bash json yaml xml go rust
```

---

### 方法3：使用脚本批量安装

运行提供的脚本：

```bash
cd /Users/zs/tools/audit.vim
./install_treesitter_parsers.sh
```

---

## ✓ 验证安装

### 检查已安装的 parsers

```vim
:TSInstallInfo
```

你应该看到 `java` 在已安装列表中（绿色勾号 ✓）。

### 检查语法高亮

打开一个 Java 文件：

```bash
nvim MainActivity.java
```

你应该看到：
- ✅ **关键字**（public, class, void 等）有颜色
- ✅ **字符串**有颜色
- ✅ **注释**有颜色
- ✅ **方法名**有颜色
- ✅ **类型**有颜色

---

## 📚 Tree-sitter 功能说明

### 什么是 Tree-sitter？

Tree-sitter 是 Neovim 的新一代语法高亮引擎：
- ✅ 比传统正则表达式更准确
- ✅ 语法感知（理解代码结构）
- ✅ 支持增量解析（性能好）
- ✅ 支持代码折叠、缩进等高级功能

### 支持的语言

Tree-sitter 支持 100+ 种语言，常用的包括：
- Java, Kotlin, C, C++, Python, JavaScript, TypeScript
- Go, Rust, Swift, Ruby, PHP
- HTML, CSS, JSON, YAML, XML, Markdown
- Bash, Lua, Vim script

---

## 🔧 配置详情

已在 `/Users/zs/.config/nvim/lua/plugins/treesitter.lua` 中配置：

```lua
{
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  lazy = false,  -- 立即加载
}
```

---

## 🎨 语法高亮示例

### 安装前（只有变量高亮）：
```java
public class MainActivity {
    private String name;  // 只有 name 有颜色
}
```

### 安装后（完整语法高亮）：
```java
public class MainActivity {  // public, class 有颜色
    private String name;     // private, String 也有颜色
}
```

---

## 🛠 常用命令

| 命令 | 功能 |
|------|------|
| `:TSInstall <lang>` | 安装指定语言的 parser |
| `:TSInstallInfo` | 查看所有可用和已安装的 parsers |
| `:TSUpdate` | 更新所有已安装的 parsers |
| `:TSUninstall <lang>` | 卸载指定 parser |
| `:TSEnable highlight` | 启用高亮 |
| `:TSDisable highlight` | 禁用高亮 |

---

## ❓ 常见问题

### Q1: 安装后还是没有高亮？

**A:** 尝试以下步骤：

1. 重新加载文件：`:e %`
2. 检查 Tree-sitter 是否启用：`:TSBufEnable highlight`
3. 检查 parser 是否安装：`:TSInstallInfo`
4. 重启 Neovim

### Q2: 大文件打开很慢？

**A:** Tree-sitter 对大文件（> 200KB）自动禁用高亮。这是性能优化。

### Q3: 如何禁用 Tree-sitter？

**A:** 删除或注释 `lua/plugins/treesitter.lua` 文件。

### Q4: 安装时提示需要编译器？

**A:** Tree-sitter parsers 需要 C 编译器。macOS 上需要安装 Xcode Command Line Tools：

```bash
xcode-select --install
```

### Q5: 某些语法高亮不正确？

**A:** 可以回退到 Vim 正则高亮：

```vim
:TSBufDisable highlight
```

---

## 🎯 对代码审计的好处

1. **快速识别代码结构**
   - 类、方法、变量一目了然
   - 快速定位关键代码

2. **减少阅读疲劳**
   - 颜色区分不同元素
   - 提高长时间审计效率

3. **辅助理解复杂代码**
   - 语法高亮帮助理解嵌套结构
   - 快速识别控制流

---

## 📝 其他配置（可选）

### 启用增量选择

在 `treesitter.lua` 中添加：

```lua
incremental_selection = {
  enable = true,
  keymaps = {
    init_selection = '<CR>',
    node_incremental = '<CR>',
    scope_incremental = '<TAB>',
    node_decremental = '<BS>',
  },
},
```

使用：
- `Enter`: 扩大选择范围
- `Tab`: 扩展到更大的作用域
- `Backspace`: 缩小选择范围

### 启用代码折叠

```lua
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldenable = false  -- 默认不折叠
```

---

## ✅ 总结

**立即执行：**
```vim
:TSInstall java
```

**验证：**
```vim
:TSInstallInfo
```

**测试：**
打开 Java 文件，查看完整的语法高亮。

祝审计顺利！🚀
