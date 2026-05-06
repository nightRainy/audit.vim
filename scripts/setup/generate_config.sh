#!/bin/bash
# =============================================================================
# audit.nvim 自动配置生成脚本
# 自动检测项目路径并生成可移植的 Neovim 配置
# =============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

echo "=========================================="
info "audit.nvim 自动配置生成器"
echo "=========================================="
echo ""

# 检测项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

info "检测到项目路径: $PROJECT_ROOT"

# Neovim 配置目录
NVIM_CONFIG="$HOME/.config/nvim"
PLUGINS_DIR="$NVIM_CONFIG/lua/plugins"

# 创建目录
mkdir -p "$PLUGINS_DIR"

# 备份现有配置
if [ -f "$PLUGINS_DIR/audit.lua" ]; then
    BACKUP="$PLUGINS_DIR/audit.lua.backup.$(date +%Y%m%d_%H%M%S)"
    warn "备份现有配置到: $BACKUP"
    cp "$PLUGINS_DIR/audit.lua" "$BACKUP"
fi

# 生成可移植的配置文件
info "生成配置文件..."

cat > "$PLUGINS_DIR/audit.lua" << EOF
-- audit.nvim 插件配置
-- 自动生成，可移植到其他设备

-- 自动检测 audit.vim 项目路径的函数
local function find_audit_vim_path()
  -- 方法 1: 检查环境变量
  if vim.env.AUDIT_VIM_PATH then
    return vim.env.AUDIT_VIM_PATH
  end

  -- 方法 2: 检查常见安装位置
  local common_paths = {
    vim.fn.expand('~/tools/audit.vim'),
    vim.fn.expand('~/.local/share/audit.vim'),
    vim.fn.expand('~/projects/audit.vim'),
    vim.fn.expand('~/workspace/audit.vim'),
  }

  for _, path in ipairs(common_paths) do
    if vim.fn.isdirectory(path) == 1 then
      return path
    end
  end

  -- 方法 3: 如果在插件管理器中作为 Git 插件安装
  -- 返回 nil，让插件管理器自动处理
  return nil
end

-- 自动检测 Mason LSP 路径
local function get_mason_bin(lsp_name)
  local mason_bin = vim.fn.expand('~/.local/share/nvim/mason/bin/' .. lsp_name)
  if vim.fn.executable(mason_bin) == 1 then
    return mason_bin
  end
  -- 如果 Mason bin 不存在，检查是否在 PATH 中
  if vim.fn.executable(lsp_name) == 1 then
    return lsp_name
  end
  return nil
end

local audit_vim_path = find_audit_vim_path()

return {
  -- audit.vim 主插件
  audit_vim_path and {
    dir = audit_vim_path,
    name = 'audit.vim',
    lazy = false,
    priority = 1100,
  } or {
    -- 如果找不到本地路径，从 Git 安装（需要配置仓库地址）
    -- 'your-github-username/audit.vim',
    dir = '$PROJECT_ROOT',  -- 当前检测到的路径
    name = 'audit.vim',
    lazy = false,
    priority = 1100,
  },

  -- 必需插件
  {
    'skywind3000/asyncrun.vim',
    lazy = false,
    priority = 1000,
  },

  {
    'stevearc/aerial.nvim',
    lazy = false,
    priority = 900,
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('aerial').setup({
        backends = { "lsp", "treesitter", "markdown" },
        layout = {
          default_direction = "left",
          width = 30,
          min_width = 20,
        },
        attach_mode = "global",
        filter_kind = false,
        highlight_on_hover = true,
        manage_folds = true,
        show_guides = true,
      })
    end,
  },

  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- 使用新的 vim.lsp.config API (Neovim 0.11+)

      -- C/C++
      if vim.fn.executable('clangd') == 1 then
        vim.lsp.config.clangd = {
          cmd = { 'clangd' },
          filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
          root_markers = { '.clangd', '.clang-tidy', '.clang-format', 'compile_commands.json', 'compile_flags.txt', 'configure.ac', '.git' },
          disable_max_lines = nil,
        }
        vim.lsp.enable('clangd')
      end

      -- Python
      if vim.fn.executable('pyright') == 1 then
        vim.lsp.config.pyright = {
          cmd = { 'pyright-langserver', '--stdio' },
          filetypes = { 'python' },
          root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
          disable_max_lines = nil,
        }
        vim.lsp.enable('pyright')
      end

      -- Rust
      if vim.fn.executable('rust-analyzer') == 1 then
        vim.lsp.config['rust-analyzer'] = {
          cmd = { 'rust-analyzer' },
          filetypes = { 'rust' },
          root_markers = { 'Cargo.toml', '.git' },
          disable_max_lines = nil,
        }
        vim.lsp.enable('rust-analyzer')
      end

      -- Go
      if vim.fn.executable('gopls') == 1 then
        vim.lsp.config.gopls = {
          cmd = { 'gopls' },
          filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
          root_markers = { 'go.work', 'go.mod', '.git' },
          disable_max_lines = nil,
        }
        vim.lsp.enable('gopls')
      end

      -- TypeScript/JavaScript
      if vim.fn.executable('typescript-language-server') == 1 then
        vim.lsp.config.ts_ls = {
          cmd = { 'typescript-language-server', '--stdio' },
          filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
          root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
          disable_max_lines = nil,
        }
        vim.lsp.enable('ts_ls')
      end

      -- Java (jdtls)
      local jdtls_cmd = get_mason_bin('jdtls')
      if jdtls_cmd then
        local workspace_dir = vim.fn.expand('~/.local/share/nvim/jdtls-workspace/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':t'))

        vim.lsp.config.jdtls = {
          cmd = { jdtls_cmd, '-data', workspace_dir },
          filetypes = { 'java' },
          root_markers = {
            'gradlew', 'build.gradle', 'build.gradle.kts',
            'settings.gradle', 'settings.gradle.kts',
            'pom.xml', '.git',
          },
          settings = {
            java = {
              eclipse = { downloadSources = true },
              maven = { downloadSources = true },
              implementationsCodeLens = { enabled = true },
              referencesCodeLens = { enabled = true },
              format = { enabled = true },
            },
          },
          disable_max_lines = nil,
        }
        vim.lsp.enable('jdtls')
      end

      -- Kotlin
      local kotlin_cmd = get_mason_bin('kotlin-language-server')
      if kotlin_cmd then
        vim.lsp.config.kotlin_language_server = {
          cmd = { kotlin_cmd },
          filetypes = { 'kotlin' },
          root_markers = { 'gradlew', 'build.gradle', 'build.gradle.kts', 'settings.gradle', '.git' },
          disable_max_lines = nil,
        }
        vim.lsp.enable('kotlin_language_server')
      end
    end,
  },

  -- 推荐插件
  {
    'junegunn/fzf',
    build = './install --all',
  },

  {
    'junegunn/fzf.vim',
    dependencies = { 'junegunn/fzf' },
    keys = {
      { '<leader>ff', '<cmd>FZF<cr>', desc = 'FZF Files' },
      { '<leader>r', '<cmd>RG<cr>', desc = 'RipGrep' },
    },
  },

  {
    'MattesGroeger/vim-bookmarks',
    keys = {
      { 'mm', '<cmd>BookmarkToggle<cr>', desc = 'Toggle Bookmark' },
      { 'mi', '<cmd>BookmarkAnnotate<cr>', desc = 'Annotate Bookmark' },
      { 'ma', '<cmd>BookmarkShowAll<cr>', desc = 'Show All Bookmarks' },
      { 'mc', '<cmd>BookmarkClear<cr>', desc = 'Clear Bookmarks' },
      { 'mx', '<cmd>BookmarkClearAll<cr>', desc = 'Clear All Bookmarks' },
    },
  },
}
EOF

success "配置文件已生成: $PLUGINS_DIR/audit.lua"

# 创建环境变量设置提示
echo ""
info "为了更好的可移植性，建议设置环境变量："
echo ""
echo "  export AUDIT_VIM_PATH=\"$PROJECT_ROOT\""
echo ""
info "可以添加到 ~/.zshrc 或 ~/.bashrc："
echo ""
echo "  echo 'export AUDIT_VIM_PATH=\"$PROJECT_ROOT\"' >> ~/.zshrc"
echo ""

# 询问是否自动添加
read -p "是否自动添加环境变量到 shell 配置? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 检测使用的 shell
    if [ -n "$ZSH_VERSION" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_RC="$HOME/.bashrc"
    else
        SHELL_RC="$HOME/.profile"
    fi

    if ! grep -q "AUDIT_VIM_PATH" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# audit.vim 项目路径" >> "$SHELL_RC"
        echo "export AUDIT_VIM_PATH=\"$PROJECT_ROOT\"" >> "$SHELL_RC"
        success "已添加到 $SHELL_RC"
        warn "请运行 'source $SHELL_RC' 或重启终端使其生效"
    else
        warn "环境变量已存在于 $SHELL_RC"
    fi
fi

echo ""
echo "=========================================="
success "配置生成完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "1. 重启 Neovim 或运行 :Lazy sync"
echo "2. 配置会自动检测 audit.vim 路径"
echo "3. 将此配置复制到其他设备即可使用"
echo ""
echo "快速部署到其他设备："
echo "  scp $PLUGINS_DIR/audit.lua user@host:~/.config/nvim/lua/plugins/"
echo ""
