# OpenCode CLI 安装指南

## 重要信息

根据 opencode.nvim 项目文档，OpenCode CLI 的官方仓库是：

**https://github.com/sst/opencode**

audit.vim 中之前文档引用的 `https://github.com/sst/opencode 是错误的，正确的 CLI 项目地址是 SST 组织维护的。

## 安装方法

### 方法 1: 访问官方仓库安装（推荐）

1. 访问 OpenCode CLI 官方仓库：
   ```
   https://github.com/sst/opencode
   ```

2. 按照官方 README 中的安装说明进行安装

3. 验证安装：
   ```bash
   opencode --version
   ```

### 方法 2: 使用包管理器（如果支持）

OpenCode CLI 可能支持以下安装方式（请访问官方仓库确认）：

**macOS (Homebrew):**
```bash
# 检查是否有 Homebrew formula
brew search opencode

# 如果有，安装
brew install opencode
```

**Node.js (npm/yarn):**
```bash
# 如果 opencode 是 Node.js 包
npm install -g opencode
# 或
yarn global add opencode
```

**Go:**
```bash
# 如果 opencode 是 Go 项目
go install github.com/sst/opencode@latest
```

**从源码编译:**
```bash
# 克隆仓库
git clone https://github.com/sst/opencode.git
cd opencode

# 根据项目的 README 编译和安装
# 可能是以下命令之一：
make install
# 或
npm install && npm run build
# 或
go build -o opencode
```

## 配置 OpenCode

安装完成后，你可能需要：

1. **设置 API Keys（如果需要）**

   OpenCode 可能需要 AI 服务的 API key，如 OpenAI、Anthropic 等：
   ```bash
   # 设置环境变量
   export OPENAI_API_KEY="your-api-key"
   export ANTHROPIC_API_KEY="your-api-key"
   ```

   或在配置文件中设置（参考 opencode 官方文档）

2. **初始化配置**
   ```bash
   # 可能需要运行初始化命令
   opencode init
   ```

## 在 Neovim 中使用

### 方法 1: 使用 audit.nvim 脚本（推荐）

如果你已经运行过 `./install_opencode.sh`，现在只需：

1. **启动 OpenCode 服务器**

   在 Neovim 中运行：
   ```vim
   :lua require('audit.opencode').start_server()
   ```

   或在终端中手动启动：
   ```bash
   opencode --port 6041
   ```

2. **检查状态**
   ```vim
   :lua require('audit.opencode').show_status()
   ```

3. **开始使用**
   - 按 `<C-a>` 询问 AI
   - 按 `<C-x>` 选择动作
   - 运行 `:OpencodeReview` 审查代码

### 方法 2: 检查健康状态

运行 Neovim 健康检查：
```vim
:checkhealth opencode
```

这会显示：
- OpenCode CLI 是否已安装
- 配置是否正确
- 依赖是否满足

## 验证安装

### 1. 检查 CLI 是否安装

```bash
which opencode
# 应该输出: /usr/local/bin/opencode 或类似路径

opencode --version
# 应该输出版本号
```

### 2. 在 Neovim 中检查

```vim
:lua print(vim.fn.executable('opencode'))
" 应该输出: 1 (表示找到了 opencode 命令)
```

### 3. 测试运行

```bash
# 测试启动 opencode 服务器
opencode --port 6041

# 应该看到服务器启动信息
# 按 Ctrl+C 停止测试
```

## 故障排除

### 问题 1: `command not found: opencode`

**原因**: OpenCode CLI 未安装或不在 PATH 中

**解决方法**:
1. 检查是否已安装：`ls -la /usr/local/bin/opencode`
2. 如果已安装但不在 PATH，添加到 PATH：
   ```bash
   # 在 ~/.bashrc 或 ~/.zshrc 中添加
   export PATH="$PATH:/path/to/opencode"
   ```
3. 重新加载配置：`source ~/.bashrc` 或 `source ~/.zshrc`

### 问题 2: `OpenCode CLI 未安装` 警告

**原因**: audit.nvim 脚本检测不到 opencode 命令

**解决方法**:
1. 确保 opencode 已安装并在 PATH 中
2. 重新运行安装脚本：`./install_opencode.sh`
3. 或手动配置（参考 example_config.lua）

### 问题 3: 服务器启动失败

**原因**: 端口被占用或权限问题

**解决方法**:
1. 尝试使用其他端口：`opencode --port 6042`
2. 检查端口是否被占用：`lsof -i :6041`
3. 确保有权限启动服务

### 问题 4: API Key 错误

**原因**: 未设置或 API key 无效

**解决方法**:
1. 设置正确的 API key 环境变量
2. 检查 API key 是否有效
3. 查看 opencode 配置文件（通常在 `~/.config/opencode/`）

## 更新 audit.vim 配置

由于 OpenCode CLI 项目地址的更正，你可能需要更新文档中的链接：

```bash
cd /path/to/audit.vim

# 替换错误的链接为正确的链接
find . -type f \( -name "*.md" -o -name "*.lua" -o -name "*.sh" \) \
  -exec sed -i '' 's|github.com/sst/opencodegithub.com/sst/opencode|g' {} +
```

## 参考资源

- **OpenCode CLI**: https://github.com/sst/opencode
- **opencode.nvim**: https://github.com/NickvanDyke/opencode.nvim
- **audit.nvim 文档**:
  - [OPENCODE_QUICKSTART.md](OPENCODE_QUICKSTART.md)
  - [INSTALL_SCRIPTS.md](INSTALL_SCRIPTS.md)
  - [example_config.lua](example_config.lua)

## 快速开始流程

完整的安装和使用流程：

```bash
# 1. 安装 OpenCode CLI
# 访问 https://github.com/sst/opencode 并按照说明安装

# 2. 验证安装
opencode --version

# 3. 配置 API Keys（如果需要）
export OPENAI_API_KEY="your-key"

# 4. 安装 opencode.nvim（使用 audit.vim 脚本）
cd /path/to/audit.vim
./install_opencode.sh

# 5. 重启 Neovim
nvim

# 6. 启动 OpenCode 服务器（在 Neovim 中）
:lua require('audit.opencode').start_server()

# 7. 开始使用
# 按 <C-a> 询问 AI
# 运行 :OpencodeReview 审查代码
```

## 获取帮助

如果遇到问题：

1. 查看 OpenCode CLI 官方文档：https://github.com/sst/opencode
2. 运行 `:checkhealth opencode` 检查配置
3. 查看 audit.nvim 文档
4. 提交 issue 到相应的项目仓库

---

**注意**: 本文档是基于公开信息编写的。具体安装方法请以 OpenCode CLI 官方仓库的 README 为准。
