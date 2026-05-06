# audit.nvim 可移植性改进总结

## 📋 改进概述

为了提高 audit.nvim 在不同设备间的可移植性，已完成以下改进：

### ✅ 主要改进

1. **自动路径检测** - 配置文件不再硬编码路径
2. **智能 LSP 查找** - 自动检测 Mason 和系统 LSP
3. **一键部署脚本** - 简化新设备配置过程
4. **环境变量支持** - 灵活的路径管理
5. **完整部署文档** - 详细的迁移指南

---

## 🔧 解决的问题

### 问题 1: 硬编码的绝对路径
**之前**:
```lua
dir = '/Users/zs/tools/audit.vim',  -- 固定路径
```

**现在**:
```lua
-- 自动检测路径的函数
local function find_audit_vim_path()
  -- 1. 检查环境变量
  if vim.env.AUDIT_VIM_PATH then
    return vim.env.AUDIT_VIM_PATH
  end

  -- 2. 检查常见位置
  local common_paths = {
    '~/tools/audit.vim',
    '~/.local/share/audit.vim',
    '~/projects/audit.vim',
  }

  for _, path in ipairs(common_paths) do
    if vim.fn.isdirectory(path) == 1 then
      return path
    end
  end

  return nil
end
```

### 问题 2: LSP 路径硬编码
**之前**:
```lua
if vim.fn.executable('jdtls') == 1 then
  -- 假设 jdtls 在 PATH 中
```

**现在**:
```lua
-- 智能检测 Mason LSP 或系统 LSP
local function get_mason_bin(lsp_name)
  local mason_bin = vim.fn.expand('~/.local/share/nvim/mason/bin/' .. lsp_name)
  if vim.fn.executable(mason_bin) == 1 then
    return mason_bin
  end
  if vim.fn.executable(lsp_name) == 1 then
    return lsp_name
  end
  return nil
end

local jdtls_cmd = get_mason_bin('jdtls')
if jdtls_cmd then
  vim.lsp.config.jdtls = {
    cmd = { jdtls_cmd, '-data', workspace_dir },
    -- ...
  }
end
```

### 问题 3: 缺少自动化部署流程
**现在提供**:
- ✅ `scripts/generate_config.sh` - 自动生成可移植配置
- ✅ `QUICK_DEPLOY.md` - 完整部署指南
- ✅ 环境变量设置辅助

---

## 📦 新增文件

### 1. `scripts/generate_config.sh`
自动配置生成脚本，功能：
- 自动检测项目路径
- 生成可移植的 Neovim 配置
- 智能 LSP 路径检测
- 可选的环境变量设置
- 备份现有配置

### 2. `QUICK_DEPLOY.md`
快速部署文档，包含：
- 3 种部署方法（一键、手动、同步）
- 完整的故障排除指南
- 配置验证步骤
- 使用示例
- 快速命令参考

### 3. `PORTABILITY.md` (本文件)
可移植性改进总结

---

## 🚀 使用方法

### 在当前设备（首次配置）

```bash
cd ~/tools/audit.vim
./scripts/generate_config.sh
```

### 部署到新设备

#### 方法 1: 使用脚本（推荐）
```bash
# 1. 克隆项目
git clone <repo-url> ~/tools/audit.vim

# 2. 运行配置脚本
cd ~/tools/audit.vim
./scripts/generate_config.sh

# 3. 启动 Neovim
nvim
```

#### 方法 2: 手动复制配置
```bash
# 1. 复制配置文件
scp ~/.config/nvim/lua/plugins/audit.lua user@newhost:~/.config/nvim/lua/plugins/

# 2. 在新设备上克隆项目
git clone <repo-url> ~/tools/audit.vim

# 3. 设置环境变量
echo 'export AUDIT_VIM_PATH="$HOME/tools/audit.vim"' >> ~/.zshrc
```

---

## 🔍 路径检测逻辑

配置文件使用以下优先级检测项目路径：

1. **环境变量**: `$AUDIT_VIM_PATH`
2. **常见位置**:
   - `~/tools/audit.vim`
   - `~/.local/share/audit.vim`
   - `~/projects/audit.vim`
   - `~/workspace/audit.vim`
3. **后备路径**: 生成时检测到的路径

LSP 路径检测优先级：

1. **Mason 安装**: `~/.local/share/nvim/mason/bin/<lsp>`
2. **系统 PATH**: 使用 `vim.fn.executable()` 检查

---

## 📝 环境变量

### 推荐设置

添加到 `~/.zshrc` 或 `~/.bashrc`:

```bash
# audit.vim 项目路径
export AUDIT_VIM_PATH="$HOME/tools/audit.vim"
```

### 优势

1. **灵活性**: 项目可以放在任意位置
2. **一致性**: 所有设备使用相同的变量名
3. **可维护性**: 更改路径只需修改一个地方

---

## 🎯 兼容性

### 支持的系统
- ✅ macOS (Intel / Apple Silicon)
- ✅ Linux (Ubuntu, Debian, Arch, etc.)
- ✅ WSL (Windows Subsystem for Linux)
- ⚠️ Windows (需要额外配置)

### 支持的 Shell
- ✅ zsh
- ✅ bash
- ✅ fish (需要手动设置环境变量)

### Neovim 版本要求
- **最低版本**: 0.5+
- **推荐版本**: 0.11+ (完整 LSP 支持)

---

## 🐛 常见问题

### Q: 配置脚本找不到项目路径？
**A**: 手动设置环境变量：
```bash
export AUDIT_VIM_PATH="/path/to/audit.vim"
```

### Q: LSP 找不到命令？
**A**: 使用 Mason 安装 LSP：
```vim
:Mason
" 搜索并安装需要的 LSP
```

### Q: 多个设备路径不同？
**A**: 在每个设备上设置 `AUDIT_VIM_PATH` 环境变量指向实际路径

### Q: 配置文件被覆盖？
**A**: 脚本会自动备份，查看：
```bash
ls ~/.config/nvim/lua/plugins/audit.lua.backup.*
```

---

## 📊 测试清单

在新设备部署后，验证以下功能：

- [ ] 项目路径正确检测
- [ ] LSP 正常启动（`:LspInfo`）
- [ ] 快捷键可用（`<Space>fg`, `<Space>fs` 等）
- [ ] avim.py 脚本可执行
- [ ] 符号大纲可用（`<Space>o`）
- [ ] 搜索功能正常（`F2`）

---

## 🔄 版本历史

### v2.0 (2026-01-26)
- ✨ 添加自动路径检测
- ✨ 添加 LSP 智能查找
- ✨ 创建一键部署脚本
- 📝 完善部署文档
- 🐛 修复大文件 LSP 禁用问题
- 🐛 修复 Java LSP workspace 错误

### v1.0
- 初始版本
- 基本的 Neovim 配置
- LSP 支持

---

## 🤝 贡献

欢迎提交改进建议！

如果您发现可移植性问题，请：
1. 提交 issue 描述问题
2. 包含您的系统信息（OS, Neovim 版本）
3. 提供错误日志

---

## 📚 相关文档

- [快速部署指南](QUICK_DEPLOY.md)
- [完整安装指南](docs/INSTALL.md)
- [故障排除](TROUBLESHOOTING.md)
- [配置示例](example_config.lua)

---

## 💡 最佳实践

1. **使用环境变量**: 在所有设备上设置 `AUDIT_VIM_PATH`
2. **使用 Mason**: 统一管理 LSP 服务器
3. **定期备份**: 备份自定义配置到云端
4. **版本管理**: 将配置加入 dotfiles 仓库
5. **文档更新**: 记录自定义修改

---

需要更多帮助？查看 [TROUBLESHOOTING.md](TROUBLESHOOTING.md) 或提交 issue。
