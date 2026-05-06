# Changelog

All notable changes to audit.vim will be documented in this file.

## [2.1.0] - 2026-01-26

### 🗂️ 文件结构重组

#### 改进
- **清爽的根目录**: 从 18 个文件减少到 9 个文件
- **分类的文档**: 文档按用途分类到 4 个子目录
- **组织的脚本**: 脚本按功能分类到 5 个子目录
- **快捷脚本**: 添加 `quick-setup.sh` 和 `check-status.sh`

#### 新目录结构
```
audit.vim/
├── docs/
│   ├── user-guide/      # 用户指南
│   ├── setup/           # 安装配置
│   ├── features/        # 功能文档
│   └── development/     # 开发文档
│
└── scripts/
    ├── setup/           # 安装配置脚本
    ├── lsp/            # LSP 相关
    ├── parsers/        # Parser 相关
    ├── opencode/       # OpenCode 相关
    └── check/          # 检查工具
```

#### 删除
- ❌ `__pycache__/` - Python 缓存（已加入 .gitignore）
- ❌ `venv/` - 虚拟环境（已加入 .gitignore）
- ❌ `.vscode/` - 编辑器配置（已加入 .gitignore）

#### 新增
- ✅ `.gitignore` - Git 忽略文件配置
- ✅ `quick-setup.sh` - 快速配置脚本
- ✅ `check-status.sh` - 快速检查脚本
- ✅ `CHANGELOG.md` - 变更日志（本文件）

### 📚 文档更新
- 更新 README.md 添加完整的项目结构说明
- 添加快速导航链接
- 标注重要文档（⭐）

---

## [2.0.0] - 2026-01-26

### ✨ 可移植性改进

#### 新增
- ✅ `scripts/setup/generate_config.sh` - 自动配置生成脚本
- ✅ `docs/user-guide/QUICK_DEPLOY.md` - 快速部署指南
- ✅ `docs/development/PORTABILITY.md` - 可移植性文档

#### 改进
- **智能路径检测**: 自动检测项目和 LSP 路径
- **环境变量支持**: 支持 `AUDIT_VIM_PATH` 环境变量
- **一键部署**: 新设备只需 3 步完成配置

#### Bug 修复
- 🐛 修复硬编码路径问题
- 🐛 修复 Java LSP toggle 失效（exit code 13）
- 🐛 修复大文件 LSP 禁用问题
- 🐛 修复 jdtls workspace 损坏问题

---

## [1.x] - 2026-01-23

### ✨ 主要功能

#### 新增
- ✅ Neovim 0.11+ LSP 支持
- ✅ Tree-sitter 语法高亮
- ✅ nvim-tree 文件浏览器
- ✅ OpenCode AI 集成
- ✅ Java/Android 项目支持

#### 支持的语言
- C/C++ (clangd)
- Python (pyright)
- Java (jdtls)
- Kotlin (kotlin-language-server)
- Rust (rust-analyzer)
- Go (gopls)
- TypeScript/JavaScript (ts_ls)

#### 功能
- 符号导航（替代 cscope）
- 异步搜索（AsyncRun + ripgrep）
- 代码大纲（aerial.nvim）
- 模糊查找（fzf）
- 书签支持
- AI 编程助手（可选）

---

## 快速链接

- **安装**: 查看 [docs/user-guide/QUICK_DEPLOY.md](docs/user-guide/QUICK_DEPLOY.md)
- **配置**: 运行 `./quick-setup.sh`
- **文档**: 查看 [docs/](docs/) 目录
- **问题**: 查看 [docs/user-guide/TROUBLESHOOTING.md](docs/user-guide/TROUBLESHOOTING.md)

---

## 版本说明

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)
遵循 [语义化版本](https://semver.org/lang/zh-CN/)
