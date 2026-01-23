-- =============================================================================
-- audit.nvim - OpenCode AI 集成配置
-- 使用 NickvanDyke/opencode.nvim
-- =============================================================================

local M = {}

-- 默认配置
M.default_opts = {
  -- 自动连接配置
  auto_connect = true,

  -- 快捷键配置
  keymaps = {
    ask = "<C-a>",      -- 询问 AI
    select = "<C-x>",   -- 选择动作
    toggle = "<C-.>",   -- 切换 opencode 终端
  },
}

-- 设置 opencode.nvim
function M.setup(opts)
  opts = opts or {}

  local ok, opencode = pcall(require, 'opencode')
  if not ok then
    vim.notify("opencode.nvim not found, skipping setup", vim.log.levels.WARN)
    return false
  end

  -- 合并配置
  local config = vim.tbl_deep_extend('force', M.default_opts, opts)

  -- 设置全局配置（如果用户提供了额外的 opencode 配置）
  if opts.opencode_opts then
    vim.g.opencode_opts = opts.opencode_opts
  end

  -- 必需：启用 autoread 用于实时重载
  vim.o.autoread = true

  -- 设置快捷键
  M.setup_keymaps(config.keymaps)

  vim.notify("OpenCode AI 已启用", vim.log.levels.INFO)
  return true
end

-- 设置快捷键
function M.setup_keymaps(keymaps)
  keymaps = keymaps or M.default_opts.keymaps

  -- Ask: 询问 AI（支持普通模式和可视模式）
  if keymaps.ask then
    vim.keymap.set({ "n", "x" }, keymaps.ask, function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask opencode AI with @this context" })
  end

  -- Select: 选择执行动作（提示词、命令等）
  if keymaps.select then
    vim.keymap.set({ "n", "x" }, keymaps.select, function()
      require("opencode").select()
    end, { desc = "Execute opencode action" })
  end

  -- Toggle: 切换 opencode 终端
  if keymaps.toggle then
    vim.keymap.set({ "n", "t" }, keymaps.toggle, function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode terminal" })
  end
end

-- 内置提示词快捷命令
function M.setup_commands()
  -- 解释诊断信息
  vim.api.nvim_create_user_command('OpencodeExplainDiagnostics', function()
    require("opencode").prompt("diagnostics")
  end, { desc = "Explain diagnostics" })

  -- 修复诊断问题
  vim.api.nvim_create_user_command('OpencodeFix', function()
    require("opencode").prompt("fix")
  end, { desc = "Fix diagnostics" })

  -- 解释代码
  vim.api.nvim_create_user_command('OpencodeExplain', function()
    require("opencode").prompt("explain")
  end, { desc = "Explain code" })

  -- 代码审查
  vim.api.nvim_create_user_command('OpencodeReview', function()
    require("opencode").prompt("review")
  end, { range = true, desc = "Review code" })

  -- 优化代码
  vim.api.nvim_create_user_command('OpencodeOptimize', function()
    require("opencode").prompt("optimize")
  end, { range = true, desc = "Optimize code" })

  -- 添加文档
  vim.api.nvim_create_user_command('OpencodeDocument', function()
    require("opencode").prompt("document")
  end, { range = true, desc = "Add documentation" })

  -- 添加测试
  vim.api.nvim_create_user_command('OpencodeTest', function()
    require("opencode").prompt("test")
  end, { range = true, desc = "Add tests" })

  -- 自由提问
  vim.api.nvim_create_user_command('OpencodeAsk', function(opts)
    local prompt = opts.args ~= "" and opts.args or nil
    require("opencode").ask(prompt)
  end, { nargs = "?", desc = "Ask opencode AI" })
end

-- 检查 opencode CLI 是否已安装
function M.check_cli()
  if vim.fn.executable('opencode') == 0 then
    vim.notify(
      "OpenCode CLI not found. Please install it first:\n" ..
      "Visit: https://github.com/NickvanDyke/opencode",
      vim.log.levels.WARN
    )
    return false
  end
  return true
end

-- 获取 opencode CLI 版本
function M.get_cli_version()
  if not M.check_cli() then
    return nil
  end

  local handle = io.popen('opencode --version 2>&1')
  if not handle then
    return nil
  end

  local result = handle:read("*a")
  handle:close()

  return result:match("(%d+%.%d+%.%d+)") or result:gsub("\n", "")
end

-- 显示 opencode 状态信息
function M.show_status()
  local cli_installed = M.check_cli()
  local version = M.get_cli_version()
  local plugin_loaded = pcall(require, 'opencode')

  local status = {
    "OpenCode Status:",
    "================",
    string.format("CLI Installed: %s", cli_installed and "✓" or "✗"),
    string.format("CLI Version: %s", version or "N/A"),
    string.format("Plugin Loaded: %s", plugin_loaded and "✓" or "✗"),
    "",
    "Available Commands:",
    "  :OpencodeExplainDiagnostics - 解释诊断信息",
    "  :OpencodeFix                - 修复诊断问题",
    "  :OpencodeExplain            - 解释代码",
    "  :OpencodeReview             - 代码审查",
    "  :OpencodeOptimize           - 优化代码",
    "  :OpencodeDocument           - 添加文档",
    "  :OpencodeTest               - 添加测试",
    "  :OpencodeAsk [prompt]       - 自由提问",
  }

  vim.notify(table.concat(status, "\n"), vim.log.levels.INFO)
end

-- 快速启动 opencode (在内置终端中)
function M.start_server()
  if not M.check_cli() then
    return
  end

  vim.cmd([[
    split | terminal opencode --port 6041
  ]])
  vim.notify("OpenCode server started on port 6041", vim.log.levels.INFO)
end

return M
