# =============================================================================
# audit.nvim 自动化安装脚本 (Windows)
# 需要管理员权限运行
# =============================================================================

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "警告: 建议以管理员权限运行此脚本" -ForegroundColor Yellow
    Write-Host "某些操作可能需要管理员权限" -ForegroundColor Yellow
    Write-Host ""
}

function Write-Info {
    param($Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param($Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warn {
    param($Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param($Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    exit 1
}

function Test-CommandExists {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# 检查并安装 Scoop
function Install-Scoop {
    if (Test-CommandExists scoop) {
        Write-Success "Scoop 已安装"
        return
    }

    Write-Info "安装 Scoop 包管理器..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

# 安装外部工具
function Install-ExternalTools {
    Write-Info "开始安装外部命令行工具..."

    Install-Scoop

    # Neovim
    if (-not (Test-CommandExists nvim)) {
        Write-Info "安装 Neovim..."
        scoop install neovim
    } else {
        Write-Success "Neovim 已安装"
    }

    # Universal Ctags
    if (-not (Test-CommandExists ctags)) {
        Write-Info "安装 Universal Ctags..."
        scoop install universal-ctags
    } else {
        Write-Success "Universal Ctags 已安装"
    }

    # Ripgrep
    if (-not (Test-CommandExists rg)) {
        Write-Info "安装 Ripgrep..."
        scoop install ripgrep
    } else {
        Write-Success "Ripgrep 已安装"
    }

    # FZF
    if (-not (Test-CommandExists fzf)) {
        Write-Info "安装 FZF..."
        scoop install fzf
    } else {
        Write-Success "FZF 已安装"
    }

    Write-Success "外部工具安装完成"
}

# 检查 Neovim 版本
function Test-NeovimVersion {
    if (-not (Test-CommandExists nvim)) {
        Write-Error "Neovim 未安装，请先安装 Neovim"
    }

    $version = nvim --version | Select-String -Pattern "NVIM v(\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
    $major, $minor = $version.Split('.')

    if ([int]$major -eq 0 -and [int]$minor -lt 5) {
        Write-Error "Neovim 版本过低 ($version)，需要 0.5 或更高版本"
    }

    Write-Success "Neovim 版本: $version"
}

# 安装 Python 依赖
function Install-PythonDeps {
    Write-Info "安装 Python 依赖..."

    if (-not (Test-CommandExists python)) {
        Write-Error "Python 未安装，请先安装 Python 3"
    }

    python -m pip install --upgrade pip
    python -m pip install -U rich

    Write-Success "Python 依赖安装完成"
}

# 安装 audit.nvim
function Install-AuditNvim {
    Write-Info "安装 audit.nvim..."

    $nvimConfig = "$env:LOCALAPPDATA\nvim"
    $pluginDir = "$nvimConfig\plugin"
    $luaDir = "$nvimConfig\lua"

    # 创建目录
    New-Item -ItemType Directory -Force -Path $pluginDir | Out-Null
    New-Item -ItemType Directory -Force -Path $luaDir | Out-Null

    # 复制文件（Windows 使用复制而不是符号链接）
    Copy-Item -Path ".\plugin\audit.vim" -Destination "$pluginDir\audit.vim" -Force
    Copy-Item -Path ".\lua\audit.lua" -Destination "$luaDir\audit.lua" -Force

    # 复制 avim.py
    $binDir = "$env:USERPROFILE\.local\bin"
    if (-not (Test-Path $binDir)) {
        New-Item -ItemType Directory -Force -Path $binDir | Out-Null
    }
    Copy-Item -Path ".\avim.py" -Destination "$binDir\avim.py" -Force

    # 添加到 PATH（如果还没有）
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$binDir*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$binDir", "User")
        Write-Success "已将 $binDir 添加到 PATH"
    }

    Write-Success "audit.nvim 安装完成"
}

# 生成插件配置
function New-PluginConfig {
    $nvimConfig = "$env:LOCALAPPDATA\nvim"
    $initLua = "$nvimConfig\init.lua"

    Write-Info "配置 Neovim 插件..."

    # 检查是否已有配置
    if (Test-Path $initLua) {
        Write-Warn "init.lua 已存在: $initLua"
        $response = Read-Host "是否要查看插件配置示例? (y/N)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            Write-Host @"

-- audit.nvim 插件配置 (lazy.nvim)
-- 将以下内容添加到 ~/.local/share/nvim/lua/plugins/audit.lua

return {
  -- 必需插件
  {
    'stevearc/aerial.nvim',
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
        },
      })
    end,
  },
  {
    'skywind3000/asyncrun.vim',
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      require('lspconfig').clangd.setup{}
    end,
  },

  -- 推荐插件
  { 'junegunn/fzf', build = './install --all' },
  { 'junegunn/fzf.vim' },
  { 'MattesGroeger/vim-bookmarks' },
}

"@ -ForegroundColor Cyan
        }
    } else {
        Write-Info "创建基础 init.lua 配置..."
        New-Item -ItemType Directory -Force -Path $nvimConfig | Out-Null
        @"
-- audit.nvim 基础配置
-- 请先安装插件管理器（推荐 lazy.nvim）

-- 如果使用 lazy.nvim，取消下面的注释
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
--   vim.fn.system({
--     "git",
--     "clone",
--     "--filter=blob:none",
--     "https://github.com/folke/lazy.nvim.git",
--     "--branch=stable",
--     lazypath,
--   })
-- end
-- vim.opt.rtp:prepend(lazypath)
-- require("lazy").setup("plugins")
"@ | Out-File -FilePath $initLua -Encoding UTF8
        Write-Success "已创建基础配置: $initLua"
    }
}

# 显示后续步骤
function Show-NextSteps {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Success "安装完成！"
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 后续步骤：" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. 重启 PowerShell 或命令提示符"
    Write-Host ""
    Write-Host "2. 安装 Neovim 插件："
    Write-Host "   打开 Neovim: nvim"
    Write-Host "   如果使用 lazy.nvim: :Lazy"
    Write-Host ""
    Write-Host "3. 安装 LSP 服务器（根据你的项目语言）："
    Write-Host "   使用 npm (需要先安装 Node.js):"
    Write-Host "   npm install -g pyright typescript typescript-language-server"
    Write-Host ""
    Write-Host "   或使用 scoop:"
    Write-Host "   scoop install llvm  # 包含 clangd"
    Write-Host ""
    Write-Host "4. 索引你的项目："
    Write-Host "   python avim.py make -t C:\path\to\your\project"
    Write-Host ""
    Write-Host "5. 打开项目："
    Write-Host "   python avim.py open C:\path\to\your\project"
    Write-Host ""
    Write-Host "📚 文档: 查看 README.md"
    Write-Host ""
}

# 主函数
function Main {
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Info "audit.nvim 自动化安装脚本 (Windows)"
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""

    # 检查是否在正确的目录
    if (-not (Test-Path "avim.py") -or -not (Test-Path "Makefile")) {
        Write-Error "请在 audit.nvim 项目根目录运行此脚本"
    }

    try {
        # 1. 安装外部工具
        Install-ExternalTools
        Write-Host ""

        # 2. 检查 Neovim 版本
        Test-NeovimVersion
        Write-Host ""

        # 3. 安装 Python 依赖
        Install-PythonDeps
        Write-Host ""

        # 4. 安装 audit.nvim
        Install-AuditNvim
        Write-Host ""

        # 5. 配置插件
        New-PluginConfig
        Write-Host ""

        # 6. 显示后续步骤
        Show-NextSteps

    } catch {
        Write-Error "安装过程中出现错误: $_"
    }
}

# 运行主函数
Main
