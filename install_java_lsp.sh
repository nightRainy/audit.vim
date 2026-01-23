#!/bin/bash
# =============================================================================
# Java LSP (jdtls) 快速安装脚本
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
info "Java LSP (jdtls) 安装脚本"
echo "=========================================="
echo ""

# 检查 Java
if ! command -v java &> /dev/null; then
    error "Java 未安装。请先安装 Java 11 或更高版本"
fi

JAVA_VERSION=$(java -version 2>&1 | grep -o 'version "[0-9.]*"' | head -1 | sed 's/version "//;s/\..*$//')
if [ "$JAVA_VERSION" -lt 11 ]; then
    error "Java 版本过低 ($JAVA_VERSION)，需要 Java 11+"
fi
success "Java 版本: $JAVA_VERSION"

# 检查 Neovim
if ! command -v nvim &> /dev/null; then
    error "Neovim 未安装"
fi
success "Neovim 已安装"

echo ""
info "选择安装方法："
echo "1. 使用 Mason.nvim（推荐，简单）"
echo "2. 手动安装 jdtls"
echo ""
read -p "请选择 (1/2): " choice

if [ "$choice" = "1" ]; then
    # 方法 1：使用 Mason
    info "安装 Mason.nvim..."

    MASON_CONFIG="$HOME/.config/nvim/lua/plugins/mason.lua"
    mkdir -p "$(dirname "$MASON_CONFIG")"

    cat > "$MASON_CONFIG" << 'EOF'
return {
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
    keys = { { '<leader>cm', '<cmd>Mason<cr>', desc = 'Mason' } },
    config = function()
      require('mason').setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim', 'neovim/nvim-lspconfig' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = {
          'jdtls',
          'kotlin_language_server',
        },
        automatic_installation = true,
      })
    end,
  },
}
EOF

    success "已创建 Mason 配置: $MASON_CONFIG"
    echo ""
    info "请执行以下步骤："
    echo "1. 重启 Neovim"
    echo "2. Mason 会自动安装 jdtls"
    echo "3. 或手动运行: :Mason 然后搜索 jdtls 并按 i 安装"

elif [ "$choice" = "2" ]; then
    # 方法 2：手动安装
    info "手动安装 jdtls..."

    LSP_DIR="$HOME/.local/share/nvim/lsp"
    JDTLS_DIR="$LSP_DIR/jdtls"
    BIN_DIR="$HOME/.local/bin"

    mkdir -p "$LSP_DIR"
    mkdir -p "$BIN_DIR"
    cd "$LSP_DIR"

    # 下载 jdtls
    info "下载 jdtls..."
    JDTLS_URL="https://www.eclipse.org/downloads/download.php?file=/jdtls/snapshots/jdt-language-server-latest.tar.gz"

    if command -v curl &> /dev/null; then
        curl -L "$JDTLS_URL" -o jdtls.tar.gz
    elif command -v wget &> /dev/null; then
        wget "$JDTLS_URL" -O jdtls.tar.gz
    else
        error "需要 curl 或 wget 来下载文件"
    fi

    # 解压
    info "解压 jdtls..."
    mkdir -p jdtls
    tar -xzf jdtls.tar.gz -C jdtls
    rm jdtls.tar.gz

    # 创建启动脚本
    info "创建启动脚本..."

    # 检测操作系统
    if [[ "$OSTYPE" == "darwin"* ]]; then
        CONFIG_DIR="config_mac"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        CONFIG_DIR="config_linux"
    else
        CONFIG_DIR="config_linux"
    fi

    cat > "$BIN_DIR/jdtls" << EOF
#!/bin/bash
JDTLS_HOME="$JDTLS_DIR"
JAR="\$JDTLS_HOME/plugins/org.eclipse.equinox.launcher_*.jar"
CONFIG="\$JDTLS_HOME/$CONFIG_DIR"

# 获取第一个匹配的 JAR 文件
JAR=\$(ls \$JDTLS_HOME/plugins/org.eclipse.equinox.launcher_*.jar | head -1)

java \\
  -Declipse.application=org.eclipse.jdt.ls.core.id1 \\
  -Dosgi.bundles.defaultStartLevel=4 \\
  -Declipse.product=org.eclipse.jdt.ls.core.product \\
  -Dlog.protocol=true \\
  -Dlog.level=ALL \\
  -Xmx2G \\
  --add-modules=ALL-SYSTEM \\
  --add-opens java.base/java.util=ALL-UNNAMED \\
  --add-opens java.base/java.lang=ALL-UNNAMED \\
  -jar "\$JAR" \\
  -configuration "\$CONFIG" \\
  "\$@"
EOF

    chmod +x "$BIN_DIR/jdtls"

    success "jdtls 安装完成！"
    success "安装位置: $JDTLS_DIR"
    success "启动脚本: $BIN_DIR/jdtls"

    # 验证
    echo ""
    info "验证安装..."
    if "$BIN_DIR/jdtls" --version &> /dev/null; then
        success "jdtls 可以正常运行"
    else
        warn "jdtls 可能无法正常运行，请检查 Java 版本"
    fi
else
    error "无效的选择"
fi

echo ""
echo "=========================================="
success "安装完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "1. 重启 Neovim"
echo "2. 打开 Android 项目: avim.py open /path/to/android/project"
echo "3. 等待 jdtls 启动（首次可能需要 1-2 分钟）"
echo "4. 检查状态: :LspInfo"
echo ""
echo "详细文档: cat ANDROID_SETUP.md"
echo ""
