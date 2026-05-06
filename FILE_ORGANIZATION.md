# 文件整理报告

整理日期: 2026-01-26

## 📊 整理成果

### 根目录文件数量

| 指标 | 之前 | 之后 | 改善 |
|------|------|------|------|
| 文件数 | 18 | 8 | ↓ 56% |
| 目录数 | 5 | 5 | 保持 |
| 临时文件 | 3 | 0 | ✅ 全部清理 |

### 根目录文件列表

**之前** (18 个文件):
```
INSTALL_SCRIPTS.md
Makefile
OPENCODE_CLI_INSTALL.md
OPENCODE_QUICKSTART.md
README.md
TROUBLESHOOTING.md
avim.py
example_config.lua
install_opencode.sh
suffixes.txt
uninstall_opencode.sh
+ __pycache__/
+ venv/
+ .vscode/
```

**之后** (8 个文件):
```
✅ CHANGELOG.md          (新增) 变更日志
✅ Makefile              (保留) 构建文件
✅ README.md             (保留) 主文档
✅ avim.py               (保留) 主程序
✅ check-status.sh       (新增) 快速检查
✅ example_config.lua    (保留) 配置示例
✅ quick-setup.sh        (新增) 快速配置
✅ suffixes.txt          (保留) 后缀列表
```

---

## 🗂️ 新目录结构

### 1. docs/ - 文档目录 (4 个子目录)

#### user-guide/ - 用户指南
```
✅ QUICK_DEPLOY.md          ⭐ 快速部署指南
✅ GETTING_STARTED.md       入门指南
✅ TROUBLESHOOTING.md       故障排除
✅ OPENCODE_QUICKSTART.md   OpenCode 快速开始
```

#### setup/ - 安装配置
```
✅ INSTALL.md               详细安装指南
✅ ANDROID_SETUP.md         Android 项目配置
✅ ANDROID_QUICKSTART.md    Android 快速开始
✅ CLANG_CONFIG.md          Clang/C++ 配置
✅ MACOS_NOTES.md           macOS 注意事项
✅ OPENCODE_CLI_INSTALL.md  OpenCode CLI 安装
```

#### features/ - 功能文档
```
✅ ASYNCRUN_FIND_GUIDE.md       AsyncRun Find 使用
✅ NVIM_TREE_GUIDE.md           nvim-tree 使用
✅ NVIM_TREE_DIAGNOSTICS_FIX.md 诊断图标修复
✅ QUICKFIX.md                  Quickfix 使用
✅ TREESITTER_SETUP.md          Tree-sitter 配置
```

#### development/ - 开发文档
```
✅ PORTABILITY.md           可移植性说明
✅ INSTALL_SCRIPTS.md       安装脚本文档
```

### 2. scripts/ - 脚本目录 (5 个子目录)

#### setup/ - 安装配置
```
✅ install.sh               Linux/macOS 安装
✅ install.ps1              Windows 安装
✅ generate_config.sh       ⭐ 自动生成配置
✅ setup_config.sh          配置设置
```

#### lsp/ - LSP 服务器
```
✅ install_java_lsp.sh      Java LSP 安装
✅ setup_clangd.sh          Clangd 配置
```

#### parsers/ - Tree-sitter
```
✅ install_parsers.sh       安装 parsers
✅ install_queries.sh       安装 queries
```

#### opencode/ - OpenCode AI
```
✅ install_opencode.sh      安装 OpenCode
✅ uninstall_opencode.sh    卸载 OpenCode
```

#### check/ - 检查工具
```
✅ check_plugins.sh         检查插件状态
✅ check_parser.sh          检查 parser 状态
```

---

## 🎯 整理原则

### 1. 分类清晰
- **用户文档**: 按使用场景分类（入门、配置、功能）
- **脚本工具**: 按功能类型分类（安装、LSP、检查等）
- **核心文件**: 保留在根目录，易于访问

### 2. 命名一致
- 文档使用大写 + 下划线: `QUICK_DEPLOY.md`
- 脚本使用小写 + 下划线: `install_java_lsp.sh`
- 快捷脚本使用短横线: `quick-setup.sh`

### 3. 易于发现
- 重要文档标注 ⭐
- README 包含完整导航
- 提供快捷脚本

### 4. 可维护性
- 清晰的目录层次（最多 2 层）
- .gitignore 忽略临时文件
- CHANGELOG 记录变更

---

## 🚀 快速上手

### 新用户
```bash
# 1. 查看主文档
cat README.md

# 2. 快速部署
./quick-setup.sh

# 3. 查看指南
cat docs/user-guide/QUICK_DEPLOY.md
```

### 开发者
```bash
# 1. 检查状态
./check-status.sh

# 2. 查看开发文档
ls docs/development/

# 3. 查看脚本
ls scripts/*/
```

---

## 📝 文件移动映射

### 文档移动

| 原位置 | 新位置 | 分类 |
|--------|--------|------|
| `QUICK_DEPLOY.md` | `docs/user-guide/` | 用户指南 |
| `TROUBLESHOOTING.md` | `docs/user-guide/` | 用户指南 |
| `OPENCODE_QUICKSTART.md` | `docs/user-guide/` | 用户指南 |
| `INSTALL_SCRIPTS.md` | `docs/development/` | 开发文档 |
| `PORTABILITY.md` | `docs/development/` | 开发文档 |
| `OPENCODE_CLI_INSTALL.md` | `docs/setup/` | 配置文档 |
| `docs/GETTING_STARTED.md` | `docs/user-guide/` | 重新分类 |
| `docs/INSTALL.md` | `docs/setup/` | 重新分类 |
| `docs/ANDROID_*.md` | `docs/setup/` | 重新分类 |
| `docs/*_GUIDE.md` | `docs/features/` | 重新分类 |

### 脚本移动

| 原位置 | 新位置 | 分类 |
|--------|--------|------|
| `install_opencode.sh` | `scripts/opencode/` | OpenCode |
| `uninstall_opencode.sh` | `scripts/opencode/` | OpenCode |
| `scripts/install.sh` | `scripts/setup/` | 安装 |
| `scripts/generate_config.sh` | `scripts/setup/` | 安装 |
| `scripts/install_java_lsp.sh` | `scripts/lsp/` | LSP |
| `scripts/setup_clangd.sh` | `scripts/lsp/` | LSP |
| `scripts/install_parsers.sh` | `scripts/parsers/` | Parser |
| `scripts/check_*.sh` | `scripts/check/` | 检查 |

---

## 🧹 清理项目

### 删除的临时文件
```
✅ __pycache__/         Python 字节码缓存
✅ venv/                Python 虚拟环境
✅ .vscode/             VS Code 配置
```

### 新增的忽略规则
创建了 `.gitignore` 文件，忽略：
- Python 缓存和虚拟环境
- 编辑器配置文件
- macOS 系统文件
- 日志文件

---

## ✅ 验证清单

整理完成后的验证：

- [x] 根目录文件减少到 10 个以内
- [x] 所有文档分类清晰
- [x] 所有脚本分类清晰
- [x] 临时文件已清理
- [x] .gitignore 已创建
- [x] README 已更新
- [x] 快捷脚本已创建
- [x] CHANGELOG 已创建
- [x] 目录结构文档已创建

---

## 💡 维护建议

### 添加新文档时
1. 确定文档类型（用户指南/配置/功能/开发）
2. 放入对应的 `docs/` 子目录
3. 在 README.md 中添加链接

### 添加新脚本时
1. 确定脚本类型（安装/LSP/检查等）
2. 放入对应的 `scripts/` 子目录
3. 如果是常用脚本，考虑在根目录创建快捷方式

### 定期维护
- 每月检查是否有过时文档
- 清理不再需要的脚本
- 更新 CHANGELOG

---

## 📚 相关文档

- [README.md](README.md) - 项目主文档
- [CHANGELOG.md](CHANGELOG.md) - 变更历史
- [docs/user-guide/QUICK_DEPLOY.md](docs/user-guide/QUICK_DEPLOY.md) - 快速开始

---

整理完成！项目现在更加清爽、易于导航和维护。🎉
