# AsyncRun Find 命令使用指南

## 配置完成 ✓

已添加三个便捷的文件查找命令，结果会显示在 quickfix 窗口中，可以直接跳转打开。

---

## 命令列表

### 1. `:Find` - 完整的 find 命令
最灵活的命令，支持所有 find 参数。

**用法：**
```vim
:Find -name "*.java"                    " 查找所有 .java 文件
:Find -iname "*main*"                   " 不区分大小写查找包含 main 的文件
:Find -name "*.xml" -path "*/res/*"     " 查找 res 目录下的所有 XML 文件
:Find -name "*.kt" -o -name "*.java"    " 查找 Kotlin 或 Java 文件
:Find -name "Android*"                  " 查找以 Android 开头的文件
```

### 2. `:FindName` - 按精确文件名查找
查找指定文件名（支持通配符，区分大小写）。

**用法：**
```vim
:FindName MainActivity.java             " 查找 MainActivity.java
:FindName "*.xml"                       " 查找所有 XML 文件
:FindName "build.gradle"                " 查找 build.gradle 文件
```

### 3. `:FindPattern` - 按模糊模式查找（不区分大小写）
最常用！模糊查找文件名，不区分大小写。

**用法：**
```vim
:FindPattern "*activity*"               " 查找名称包含 activity 的文件
:FindPattern "*main*"                   " 查找名称包含 main 的文件
:FindPattern "*.gradle"                 " 查找所有 Gradle 文件
:FindPattern "*service*.java"           " 查找包含 service 的 Java 文件
```

---

## 使用流程

### 标准工作流程

1. **执行查找命令**
   ```vim
   :FindPattern "*activity*.java"
   ```

2. **查看 quickfix 窗口**
   - 命令执行后，quickfix 窗口会自动显示搜索结果
   - 如果没有自动打开，按 `<leader>q`（空格 + q）切换 quickfix 窗口

3. **在 quickfix 中导航**
   - `j/k` 或 `↑/↓`: 上下移动选择文件
   - `Enter`: 打开选中的文件
   - `:cnext` 或 `:cn`: 跳转到下一个结果
   - `:cprev` 或 `:cp`: 跳转到上一个结果
   - `:cfirst`: 跳转到第一个结果
   - `:clast`: 跳转到最后一个结果

4. **关闭 quickfix**
   - 按 `<leader>q`（空格 + q）再次切换
   - 或按 `:cclose`

---

## 快捷键（ReadOnly 模式）

如果使用 `python3 avim.py open` 打开项目（ReadOnly 模式），可以使用：

- `J`: 下一个 quickfix 结果（:cnext）
- `K`: 上一个 quickfix 结果（:cprev）
- `H`: 较旧的 quickfix 列表（:colder）
- `L`: 较新的 quickfix 列表（:cnewer）
- `<leader>q`: 切换 quickfix 窗口

---

## 实用示例

### Android/Java 项目

```vim
" 查找所有 Activity
:FindPattern "*activity*.java"

" 查找所有 Fragment
:FindPattern "*fragment*.java"

" 查找 AndroidManifest.xml
:FindName AndroidManifest.xml

" 查找所有布局文件
:FindPattern "*.xml"

" 查找 strings.xml
:FindName strings.xml

" 查找所有 Kotlin 文件
:Find -name "*.kt"

" 查找所有 Service 类
:FindPattern "*service*.java"

" 查找 gradle 配置文件
:FindPattern "*.gradle"
```

### 通用场景

```vim
" 查找配置文件
:FindPattern "*.conf"
:FindPattern "*.config"

" 查找所有头文件
:Find -name "*.h"

" 查找 README 文件
:FindPattern "*readme*"

" 查找特定目录下的文件
:Find -path "*/src/main/*" -name "*.java"

" 排除某些目录
:Find -name "*.java" -not -path "*/test/*"
```

---

## 高级技巧

### 1. 组合条件查找

```vim
" 查找 Java 或 Kotlin 文件
:Find -name "*.java" -o -name "*.kt"

" 查找大小超过 1MB 的文件
:Find -name "*.jar" -size +1M

" 查找最近修改的文件
:Find -name "*.java" -mtime -7
```

### 2. 快速跳转

在 quickfix 中：
- `Ctrl-w Ctrl-w`: 在 quickfix 和编辑窗口间切换
- `Ctrl-w p`: 跳转到上一个窗口
- `Ctrl-w o`: 只保留当前窗口

### 3. 保存搜索历史

Neovim 会保存多个 quickfix 列表：
- `:colder`: 返回上一个搜索结果
- `:cnewer`: 前进到下一个搜索结果
- `:chistory`: 查看 quickfix 历史

---

## 配置原理

所有命令都使用 `AsyncRun` 异步执行，不会阻塞编辑器：

```vim
AsyncRun -errorformat=%f -cwd=<root> find . -type f [参数]
```

- `-errorformat=%f`: 告诉 Vim 每行都是一个文件路径
- `-cwd=<root>`: 在项目根目录执行
- `find . -type f`: 只查找文件（不包括目录）

---

## 排查问题

### 搜索结果为空？
1. 确认你在正确的项目目录
2. 检查通配符是否需要引号：`:FindPattern "*pattern*"`
3. 尝试不区分大小写：使用 `:FindPattern` 或 `:Find -iname`

### Quickfix 没有自动打开？
按 `<leader>q`（空格 + q）手动打开

### 无法打开文件？
确保文件路径正确，使用绝对路径搜索：
```vim
:Find -path "*完整路径*"
```

---

## 与其他功能配合

### 配合 Grep 使用

1. 先用 Find 找到文件：
   ```vim
   :FindPattern "*activity*.java"
   ```

2. 再在这些文件中搜索内容：
   ```vim
   :Grep "onCreate"
   ```

### 配合 FZF 使用

- `<leader>ff`: 使用 FZF 模糊查找文件（更快）
- `:Find`: 使用 find 精确查找（更灵活）

### 配合 nvim-tree 使用

1. 用 Find 命令找到文件
2. 按 `<leader>E` 在文件树中定位该文件
3. 浏览周围的文件结构

---

## 性能提示

对于大型项目（如 Android Framework）：
- 优先使用 `:FindName` 精确查找
- 使用 `-path` 限制搜索范围
- 排除不需要的目录（build、.git 等）

```vim
" 好：限制范围
:Find -path "*/frameworks/base/*" -name "*.java"

" 慢：搜索整个项目
:Find -name "*.java"
```

---

## 快速参考

| 命令 | 用途 | 示例 |
|-----|------|------|
| `:Find` | 完整 find 命令 | `:Find -name "*.java"` |
| `:FindName` | 精确文件名 | `:FindName MainActivity.java` |
| `:FindPattern` | 模糊匹配（推荐） | `:FindPattern "*activity*"` |
| `<leader>q` | 切换 quickfix | `空格 + q` |
| `:cnext` / `J` | 下一个结果 | - |
| `:cprev` / `K` | 上一个结果 | - |

祝你审计愉快！🚀
