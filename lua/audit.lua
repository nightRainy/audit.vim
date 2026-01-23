-- =============================================================================
-- audit.nvim - Lua 配置模块
-- =============================================================================

local M = {}

-- 设置 aerial.nvim
function M.setup_aerial()
  local ok, aerial = pcall(require, 'aerial')
  if not ok then
    vim.notify("aerial.nvim not found", vim.log.levels.WARN)
    return
  end

  aerial.setup({
    backends = { "lsp", "treesitter", "markdown" },
    layout = {
      default_direction = "left",
      width = 30,
    },
    attach_mode = "global",
    filter_kind = false,
    highlight_on_hover = true,
    manage_folds = true,
  })
end

-- 设置 LSP 快捷键
function M.setup_lsp_keymaps(bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- 符号导航（替代 cscope）
  vim.keymap.set('n', '<leader>fs', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>fg', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', '<leader>fc', vim.lsp.buf.incoming_calls, opts)
  vim.keymap.set('n', '<leader>ft', vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', '<leader>fd', vim.lsp.buf.outgoing_calls, opts)

  -- 额外的 LSP 功能
  vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', '<leader>di', vim.diagnostic.open_float, opts)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
end

-- 确保特殊 buffer 可修改（用于只读模式）
function M.ensure_special_buffers_modifiable()
  vim.api.nvim_create_autocmd({ "BufNew", "BufEnter", "BufWinEnter" }, {
    pattern = "*",
    callback = function(args)
      local bufnr = args.buf
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
      local bufname = vim.api.nvim_buf_get_name(bufnr)

      -- 检查是否是特殊 buffer
      if buftype ~= "" and buftype ~= "acwrite" or
         bufname:match("^health://") or
         vim.bo[bufnr].filetype == "checkhealth" then
        vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
        vim.api.nvim_set_option_value("readonly", false, { buf = bufnr })
      end
    end,
  })
end

-- 设置 OpenCode AI（可选）
function M.setup_opencode(opencode_opts)
  local ok, opencode_config = pcall(require, 'audit.opencode')
  if not ok then
    vim.notify("audit.opencode module not found", vim.log.levels.WARN)
    return false
  end

  -- 检查 CLI 是否安装
  if not opencode_config.check_cli() then
    return false
  end

  -- 设置 OpenCode
  local success = opencode_config.setup(opencode_opts or {})
  if success then
    -- 设置内置命令
    opencode_config.setup_commands()
    vim.notify("OpenCode AI 已集成到 audit.nvim", vim.log.levels.INFO)
  end

  return success
end

-- 初始化函数
function M.setup(opts)
  opts = opts or {}

  -- 设置 aerial
  M.setup_aerial()

  -- 如果在只读审计模式下，确保特殊 buffer 可修改
  if vim.env.AVIM_SRC ~= nil and vim.env.AVIM_SRC ~= "" then
    M.ensure_special_buffers_modifiable()
  end

  -- 设置 LSP on_attach 回调
  local old_on_attach = opts.on_attach
  opts.on_attach = function(client, bufnr)
    M.setup_lsp_keymaps(bufnr)
    if old_on_attach then
      old_on_attach(client, bufnr)
    end
  end

  -- 可选：设置 OpenCode AI
  if opts.opencode then
    M.setup_opencode(opts.opencode)
  end

  return opts
end

return M
