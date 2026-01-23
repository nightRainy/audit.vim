# OpenCode 安装/卸载脚本使用说明

本项目提供了自动化脚本，帮助你快速安装或卸载 OpenCode AI 插件。

## 📦 安装脚本

### 功能

`install_opencode.sh` 脚本会自动：

1. ✅ 检测你的 Neovim 配置目录和配置文件
2. ✅ 识别你使用的插件管理器（lazy.nvim, packer.nvim, vim-plug）
3. ✅ 备份原有配置文件
4. ✅ 添加 opencode.nvim 插件声明
5. ✅ 添加 OpenCode 初始化配置和快捷键
6. ✅ 检查 OpenCode CLI 是否已安装

### 使用方法

```bash
# 进入 audit.vim 目录
cd /path/to/audit.vim

# 运行安装脚本
./install_opencode.sh
```

### 执行流程示例

```
==========================================
  OpenCode AI 插件安装脚本
==========================================

[INFO] 检测 Neovim 配置目录...
[SUCCESS] 找到配置目录: /Users/username/.config/nvim

[INFO] 检测配置文件...
[SUCCESS] 配置文件: /Users/username/.config/nvim/init.lua

[INFO] 检查是否已安装 opencode...

[INFO] 备份配置文件...
[SUCCESS] 配置文件已备份到: /Users/username/.config/nvim/init.lua.backup.20260123_143022

[INFO] 检测插件管理器...
[SUCCESS] 检测到插件管理器: lazy

[INFO] 添加 opencode.nvim 插件配置...
[SUCCESS] 已添加 opencode.nvim 插件到 lazy.nvim 配置

[INFO] 添加 OpenCode 初始化配置...
[SUCCESS] 已添加 OpenCode 初始化配置

[INFO] 检查 OpenCode CLI...
[WARNING] OpenCode CLI 未安装
[INFO] 请访问 https://github.com/NickvanDyke/opencode 安装 CLI

==========================================
[SUCCESS] 安装完成！
==========================================

下一步：
  1. 重启 Neovim 或运行 :source /Users/username/.config/nvim/init.lua
  2. Lazy.nvim 会自动安装插件
  3. 如果 OpenCode CLI 未安装，请先安装：
     https://github.com/NickvanDyke/opencode
  4. 启动 OpenCode 服务器：
     :lua require('audit.opencode').start_server()
  5. 开始使用：
     - 按 <C-a> 询问 AI
     - 按 <C-x> 选择动作
     - 运行 :OpencodeReview 审查代码

配置文件备份: /Users/username/.config/nvim/init.lua.backup.20260123_143022
如有问题，可以使用备份恢复配置
```

### 支持的插件管理器

- ✅ **lazy.nvim** - 自动检测并添加到插件列表
- ✅ **packer.nvim** - 自动检测并添加到插件列表
- ✅ **vim-plug** - 自动检测并添加 Plug 声明
- ⚠️ **其他管理器** - 会提示手动添加

### 安全特性

1. **自动备份**: 修改前会自动备份配置文件，格式为 `init.lua.backup.YYYYMMDD_HHMMSS`
2. **重复检测**: 检测到已有配置会提示是否继续
3. **错误回滚**: 如果安装失败，会自动恢复备份
4. **只添加不删除**: 不会删除你的任何现有配置

### 添加的内容

脚本会在你的配置文件中添加：

**1. 插件声明**（在插件管理器配置中）

```lua
-- OpenCode AI 插件配置（由 install_opencode.sh 自动添加）
{
  "NickvanDyke/opencode.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "folke/snacks.nvim",
      opts = {
        input = {},
        picker = {},
        terminal = {},
      },
    },
  },
  config = function()
    -- 配置会由 audit.opencode 模块处理
  end,
},
```

**2. OpenCode 初始化配置**（在文件末尾）

```lua
-- =============================================================================
-- OpenCode AI 配置（由 install_opencode.sh 自动添加）
-- =============================================================================

local opencode_config = require('audit.opencode')

if opencode_config.check_cli() then
  opencode_config.setup({
    keymaps = {
      ask = "<C-a>",
      select = "<C-x>",
      toggle = "<C-.>",
    },
  })

  opencode_config.setup_commands()
  vim.notify("OpenCode AI 已启用", vim.log.levels.INFO)
else
  vim.notify("OpenCode CLI 未安装...", vim.log.levels.WARN)
end

-- 快捷键和命令说明...
```

## 🗑️ 卸载脚本

### 功能

`uninstall_opencode.sh` 脚本会自动：

1. ✅ 检测你的 Neovim 配置
2. ✅ 备份配置文件
3. ✅ 移除所有由 `install_opencode.sh` 添加的内容
4. ✅ 清理空白行

### 使用方法

```bash
# 进入 audit.vim 目录
cd /path/to/audit.vim

# 运行卸载脚本
./uninstall_opencode.sh
```

### 执行流程示例

```
==========================================
  OpenCode AI 插件卸载脚本
==========================================

[INFO] 检测 Neovim 配置目录...
[SUCCESS] 找到配置目录: /Users/username/.config/nvim

[INFO] 检测配置文件...
[SUCCESS] 配置文件: /Users/username/.config/nvim/init.lua

[WARNING] 即将从配置文件中移除 OpenCode 相关配置
是否继续？(y/n): y

[INFO] 备份配置文件...
[SUCCESS] 配置文件已备份到: /Users/username/.config/nvim/init.lua.backup.20260123_144511

[INFO] 移除 OpenCode 配置...
[SUCCESS] 已移除 OpenCode 配置

==========================================
[SUCCESS] 卸载完成！
==========================================

下一步：
  1. 重启 Neovim 或运行 :source /Users/username/.config/nvim/init.lua
  2. 如果使用插件管理器，可能需要手动移除插件：
     - lazy.nvim: :Lazy clean
     - packer.nvim: :PackerClean
     - vim-plug: :PlugClean

配置文件备份: /Users/username/.config/nvim/init.lua.backup.20260123_144511
如需恢复，运行: cp /Users/username/.config/nvim/init.lua.backup.20260123_144511 /Users/username/.config/nvim/init.lua
```

### 安全特性

1. **确认提示**: 删除前会要求确认
2. **自动备份**: 删除前会自动备份配置文件
3. **精确匹配**: 只移除由安装脚本添加的内容
4. **错误回滚**: 如果卸载失败，会自动恢复备份

## 🔧 故障排除

### 问题 1: 脚本没有执行权限

```bash
# 解决方法
chmod +x install_opencode.sh
chmod +x uninstall_opencode.sh
```

### 问题 2: 找不到配置文件

脚本会自动检测以下位置：
- `~/.config/nvim/init.lua`
- `~/.config/nvim/init.vim`
- `~/.nvim/init.lua`
- `~/.nvim/init.vim`

如果你的配置在其他位置，请手动配置。

### 问题 3: 未检测到插件管理器

如果脚本未检测到你的插件管理器，你可以：

1. 手动添加插件声明到你的插件管理器配置中
2. 参考 `example_config.lua` 中的配置
3. 查看 README.md 中的手动安装说明

### 问题 4: 安装后配置重复

如果不小心运行了多次安装脚本，导致配置重复：

1. 运行卸载脚本：`./uninstall_opencode.sh`
2. 或手动恢复备份文件
3. 重新运行安装脚本

### 问题 5: 需要恢复原配置

所有备份文件都保存在配置目录中，格式为：
```
init.lua.backup.YYYYMMDD_HHMMSS
```

恢复方法：
```bash
# 列出所有备份
ls -la ~/.config/nvim/init.lua.backup.*

# 恢复特定备份
cp ~/.config/nvim/init.lua.backup.20260123_143022 ~/.config/nvim/init.lua
```

## 📝 手动安装

如果你不想使用自动化脚本，可以：

1. 参考 [OPENCODE_QUICKSTART.md](OPENCODE_QUICKSTART.md) 手动配置
2. 参考 [example_config.lua](example_config.lua) 获取完整配置示例
3. 查看 [README.md](README.md) 中的详细说明

## 🤝 获取帮助

如果遇到问题：

1. 查看脚本输出的错误信息
2. 检查备份文件是否存在
3. 参考项目文档：
   - [OPENCODE_QUICKSTART.md](OPENCODE_QUICKSTART.md)
   - [README.md](README.md)
4. 提交 Issue 到项目仓库

## ⚠️ 注意事项

1. **备份重要**: 虽然脚本会自动备份，但建议手动备份重要配置
2. **检查配置**: 安装后建议检查生成的配置是否符合预期
3. **测试功能**: 安装后在测试项目中测试功能
4. **CLI 安装**: 脚本不会安装 OpenCode CLI，需要手动安装

## 📊 脚本特性对比

| 特性 | 安装脚本 | 卸载脚本 | 手动配置 |
|------|---------|---------|---------|
| 自动检测配置 | ✅ | ✅ | ❌ |
| 自动备份 | ✅ | ✅ | ❌ |
| 插件管理器适配 | ✅ | ❌ | ✅ |
| 错误回滚 | ✅ | ✅ | ❌ |
| 完全控制 | ❌ | ❌ | ✅ |
| 学习配置 | ❌ | ❌ | ✅ |

## 🎯 推荐使用场景

- ✅ **使用脚本**: 快速试用、批量部署、懒人配置
- ✅ **手动配置**: 学习 Neovim、精细控制、特殊需求

---

**Happy Coding! 🚀**
