# 故障排除指南

## 常见错误和解决方案

### ❌ 错误：`module 'audit.opencode' not found`

**错误信息：**
```
Error: module 'audit.opencode' not found:
  no field package.preload['audit.opencode']
  ...
```

**原因：**
audit.vim 插件本身没有正确加载到 Neovim 的 runtimepath 中。

**解决方案：**

#### 方案 1: 使用插件管理器加载（推荐）

如果你使用 **lazy.nvim**，在 `~/.config/nvim/lua/plugins/audit.lua` 中添加：

```lua
return {
  -- audit.vim 主插件（本地路径）
  {
    dir = '/Users/zs/tools/audit.vim',  -- 修改为你的实际路径
    name = 'audit.vim',
    lazy = false,
    priority = 1100,
  },

  -- 其他依赖插件...
}
```

如果你使用 **packer.nvim**：

```lua
use {
  '/Users/zs/tools/audit.vim',  -- 本地路径
  as = 'audit.vim',
}
```

如果你使用 **vim-plug**：

```vim
Plug '/Users/zs/tools/audit.vim'
```

#### 方案 2: 手动添加到 runtimepath

在 `init.lua` 的**开头**添加（在所有 `require` 之前）：

```lua
-- 添加 audit.vim 到 runtimepath
vim.opt.runtimepath:prepend('/Users/zs/tools/audit.vim')
```

#### 方案 3: 符号链接到 Neovim 插件目录

```bash
# 创建符号链接
mkdir -p ~/.local/share/nvim/site/pack/plugins/start/
ln -s /Users/zs/tools/audit.vim ~/.local/share/nvim/site/pack/plugins/start/audit.vim
```

### ❌ 错误：OpenCode 配置在插件加载之前执行

**症状：**
即使 audit.vim 已添加到插件配置，仍然报错找不到模块。

**原因：**
`init.lua` 中的 OpenCode 配置代码在插件加载之前就执行了。

**解决方案：**

确保 OpenCode 配置代码放在 `init.lua` 的**末尾**，或者使用 `VimEnter` 事件：

```lua
-- 方法 1: 放在 init.lua 末尾（在 lazy.setup 之后）
require("lazy").setup("plugins")

-- 确保在这里调用 OpenCode 配置
local opencode_config = require('audit.opencode')
if opencode_config.check_cli() then
  opencode_config.setup()
  opencode_config.setup_commands()
end
```

或者：

```lua
-- 方法 2: 使用 VimEnter 事件延迟加载
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local ok, opencode_config = pcall(require, 'audit.opencode')
    if ok and opencode_config.check_cli() then
      opencode_config.setup()
      opencode_config.setup_commands()
    end
  end,
})
```

### ❌ 错误：`OpenCode CLI 未安装`

**症状：**
```
[WARNING] OpenCode CLI 未安装
[INFO] 请访问 https://github.com/sst/opencode 安装 CLI
```

**这不是错误！** 这是正常的警告提示。

**解决方案：**

1. 访问 https://github.com/sst/opencode
2. 按照官方说明安装 OpenCode CLI
3. 验证安装：`opencode --version`
4. 重新打开 Neovim

详细安装指南请参考：[OPENCODE_CLI_INSTALL.md](OPENCODE_CLI_INSTALL.md)

### ❌ 错误：插件快捷键不工作

**症状：**
按 `<C-a>` 或其他快捷键没有反应。

**可能原因和解决方案：**

1. **检查插件是否加载**
   ```vim
   :lua print(vim.inspect(package.loaded['audit.opencode']))
   ```
   如果返回 `nil`，说明模块没有加载。

2. **检查 OpenCode CLI 是否安装**
   ```vim
   :lua require('audit.opencode').show_status()
   ```

3. **快捷键冲突**
   检查是否有其他插件占用了相同的快捷键：
   ```vim
   :verbose map <C-a>
   ```

4. **手动设置快捷键**
   ```lua
   vim.keymap.set({'n', 'x'}, '<C-a>', function()
     require('opencode').ask("@this: ", { submit = true })
   end, { desc = "Ask opencode" })
   ```

### ❌ 错误：命令未定义

**症状：**
```
E492: Not an editor command: OpencodeReview
```

**原因：**
`setup_commands()` 没有被调用。

**解决方案：**

确保在配置中调用了 `setup_commands()`：

```lua
local opencode_config = require('audit.opencode')
if opencode_config.check_cli() then
  opencode_config.setup()
  opencode_config.setup_commands()  -- 必须调用这个
end
```

### ❌ 错误：`asyncrun.vim` 未找到

**症状：**
```
E492: Not an editor command: AsyncRun!
```

**解决方案：**

确保在插件配置中添加了 asyncrun.vim：

```lua
{
  'skywind3000/asyncrun.vim',
  lazy = false,
  priority = 1000,
}
```

## 验证安装

### 1. 检查插件是否加载

```vim
:lua print(vim.fn.exists(':AsyncRun'))      " 应该返回 2
:lua print(vim.fn.exists(':AerialToggle'))  " 应该返回 2
:lua print(vim.fn.executable('opencode'))   " 应该返回 1（如果 CLI 已安装）
```

### 2. 检查 audit.opencode 模块

```vim
:lua local ok, mod = pcall(require, 'audit.opencode'); print('Loaded:', ok)
```

应该显示 `Loaded: true`

### 3. 查看 OpenCode 状态

```vim
:lua require('audit.opencode').show_status()
```

应该显示：
```
OpenCode Status:
================
CLI Installed: ✓
CLI Version: x.x.x
Plugin Loaded: ✓
...
```

### 4. 测试快捷键

1. 打开一个代码文件
2. 按 `<C-a>` 应该出现输入提示
3. 按 `<C-x>` 应该出现动作选择器

### 5. 测试命令

```vim
:OpencodeExplain
:OpencodeReview
```

## 完整的配置检查清单

- [ ] audit.vim 插件已添加到插件管理器配置
- [ ] asyncrun.vim 已安装
- [ ] aerial.nvim 已安装
- [ ] opencode.nvim 已安装（如果使用 OpenCode）
- [ ] OpenCode CLI 已安装（如果使用 OpenCode）
- [ ] OpenCode 配置在 `lazy.setup()` 之后
- [ ] 调用了 `setup_commands()`
- [ ] Neovim 版本 >= 0.5

## 获取帮助

如果以上方法都无法解决问题：

1. 查看 Neovim 日志：`:messages`
2. 运行健康检查：`:checkhealth opencode`
3. 查看 [OPENCODE_QUICKSTART.md](OPENCODE_QUICKSTART.md)
4. 查看 [OPENCODE_CLI_INSTALL.md](OPENCODE_CLI_INSTALL.md)
5. 提交 issue 到项目仓库

## 调试技巧

### 启用详细日志

```lua
-- 在 init.lua 开头添加
vim.lsp.set_log_level("debug")
```

### 检查 runtimepath

```vim
:echo &runtimepath
```

确保包含 audit.vim 的路径。

### 手动加载模块测试

```vim
:lua require('audit.opencode')
```

如果有错误会显示详细信息。

---

**提示：** 大多数问题都是因为 audit.vim 主插件没有正确加载。确保在插件管理器中添加了 audit.vim 的配置！
