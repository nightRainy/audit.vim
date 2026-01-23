#!/bin/bash
# 安装 Tree-sitter queries（高亮定义文件）

set -e

QUERIES_DIR="$HOME/.local/share/nvim/site/queries"
WORK_DIR="/tmp/treesitter-queries"

echo "================================"
echo "安装 Tree-sitter Queries"
echo "================================"
echo ""

mkdir -p "$QUERIES_DIR"
mkdir -p "$WORK_DIR"

install_queries() {
    local lang=$1
    echo "[$lang] 安装 queries..."

    cd "$WORK_DIR"
    rm -rf "tree-sitter-$lang"

    if ! git clone "https://github.com/tree-sitter/tree-sitter-${lang}.git" --depth=1 --quiet 2>/dev/null; then
        echo "  ⚠ 跳过（仓库不存在）"
        return 1
    fi

    cd "tree-sitter-$lang"

    # 查找 queries 目录
    if [ -d "queries" ]; then
        mkdir -p "$QUERIES_DIR/$lang"
        cp -r queries/* "$QUERIES_DIR/$lang/" 2>/dev/null || true
        echo "  ✓ 成功"
        return 0
    else
        echo "  ⚠ 无 queries 目录"
        return 1
    fi
}

# 安装所有已有 parser 的 queries
echo "安装 queries 文件..."
echo ""

install_queries "java"
install_queries "c"
install_queries "cpp"
install_queries "python"
install_queries "javascript"
install_queries "typescript"
install_queries "go"
install_queries "bash"
install_queries "json"

echo ""
echo "清理..."
rm -rf "$WORK_DIR"

echo ""
echo "================================"
echo "✅ Queries 安装完成！"
echo ""
echo "已安装的语言:"
ls -1 "$QUERIES_DIR" 2>/dev/null | while read -r lang; do
    if [ -f "$QUERIES_DIR/$lang/highlights.scm" ]; then
        echo "  ✓ $lang"
    else
        echo "  ⚠ $lang (缺少 highlights.scm)"
    fi
done
echo ""
echo "现在重启 Neovim，语法高亮应该正常工作！"
echo "================================"
