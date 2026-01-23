-- =============================================================================
-- audit.nvim 示例配置文件
-- 将此文件的内容添加到你的 ~/.config/nvim/init.lua 中
-- =============================================================================

-- 1. 使用插件管理器安装所需插件（以 lazy.nvim 为例）
require("lazy").setup({
  -- 必需插件
  {
    "stevearc/aerial.nvim",
    opts = {
      backends = { "lsp", "treesitter", "markdown" },
      layout = {
        default_direction = "left",
        width = 30,
      },
    },
  },
  {
    "skywind3000/asyncrun.vim",
  },
  {
    "neovim/nvim-lspconfig",
  },

  -- 推荐插件
  {
    "junegunn/fzf",
    build = "./install --bin",
  },
  {
    "junegunn/fzf.vim",
  },
  {
    "MattesGroeger/vim-bookmarks",
  },

  -- 可选：OpenCode AI 编程助手
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
      -- OpenCode 配置会由 audit.opencode 模块处理
    end,
  },
})

-- 2. 设置 LSP（示例：C/C++ 项目）
require("lspconfig").clangd.setup({
  on_attach = function(client, bufnr)
    -- audit.nvim 的 LSP 快捷键已在 plugin/audit.vim 中定义
  end,
})

-- 3. （可选）加载 audit.lua 模块进行统一配置
local audit = require("audit")
audit.setup({
  -- 可选：启用 OpenCode AI
  opencode = {
    keymaps = {
      ask = "<C-a>",      -- 询问 AI
      select = "<C-x>",   -- 选择动作
      toggle = "<C-.>",   -- 切换终端
    },
  },
})

-- 4. 或者单独配置 OpenCode（推荐）
local opencode_config = require("audit.opencode")
if opencode_config.check_cli() then
  opencode_config.setup({
    -- 自定义快捷键（可选）
    keymaps = {
      ask = "<C-a>",      -- 询问 AI
      select = "<C-x>",   -- 选择动作
      toggle = "<C-.>",   -- 切换终端
    },
    -- 额外的 opencode.nvim 配置（可选）
    opencode_opts = {
      -- 在 opencode.nvim 文档中查看更多配置选项
    },
  })

  -- 设置内置命令
  opencode_config.setup_commands()

  -- 可选：显示状态
  vim.notify("OpenCode AI 已启用", vim.log.levels.INFO)
else
  vim.notify("OpenCode CLI 未找到，跳过 OpenCode 配置", vim.log.levels.WARN)
end

-- =============================================================================
-- 使用说明
-- =============================================================================

--[[
1. 确保已安装 audit.vim 插件：
   git clone https://github.com/your-repo/audit.nvim.git ~/.local/share/nvim/site/pack/plugins/start/audit.nvim

2. 安装外部工具：
   - macOS: brew install universal-ctags ripgrep fzf neovim
   - Linux: sudo apt install universal-ctags ripgrep fzf neovim

3. （可选）安装 OpenCode CLI：
   访问 https://github.com/sst/opencode 获取安装说明

4. 将本文件的配置内容添加到 ~/.config/nvim/init.lua

5. 重启 Neovim 或运行 :source ~/.config/nvim/init.lua

6. 使用 avim.py 索引项目：
   avim.py make -t /path/to/your/project

7. 使用 avim.py 打开项目：
   avim.py open /path/to/your/project

8. （可选）启动 OpenCode 服务器：
   :lua require('audit.opencode').start_server()

9. 开始使用：
   - 按 <C-a> 询问 AI
   - 按 <C-x> 选择动作
   - 运行 :OpencodeReview 审查代码
   - 运行 :OpencodeOptimize 优化代码
]]
