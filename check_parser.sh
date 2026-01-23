#!/bin/bash
# 检查 Tree-sitter Parser 安装状态

echo "================================"
echo "Tree-sitter Parser 安装检查"
echo "================================"
echo ""

PARSER_DIR="$HOME/.local/share/nvim/site/parser"

# 检查目录是否存在
if [ ! -d "$PARSER_DIR" ]; then
    echo "❌ Parser 目录不存在: $PARSER_DIR"
    exit 1
fi

echo "📂 Parser 目录: $PARSER_DIR"
echo ""

# 统计已安装的 parsers
count=$(ls "$PARSER_DIR"/*.so 2>/dev/null | wc -l | tr -d ' ')

if [ "$count" -eq 0 ]; then
    echo "❌ 没有安装任何 parser"
    exit 1
fi

echo "✅ 已安装 $count 个 parsers:"
echo ""

# 列出所有 parsers 及其大小
ls -lh "$PARSER_DIR"/*.so | awk '{
    size = $5
    name = $9
    gsub(/.*\//, "", name)
    gsub(/\.so$/, "", name)

    # 特殊标记 Java
    if (name == "java") {
        printf "  🟢 %-15s %8s  <- Java (重点!)\n", name, size
    } else {
        printf "  ✓  %-15s %8s\n", name, size
    }
}'

echo ""
echo "================================"

# 检查 Java 是否存在
if [ -f "$PARSER_DIR/java.so" ]; then
    echo "✅ Java parser 安装成功！"
    echo ""
    echo "测试方法："
    echo "  1. 打开 Java 文件："
    echo "     nvim SomeFile.java"
    echo ""
    echo "  2. 在 Neovim 中检查："
    echo "     :lua print(vim.treesitter.language.require_language('java', nil, true))"
    echo ""
    echo "  3. 应该看到完整的语法高亮"
else
    echo "⚠️  Java parser 未安装"
    echo ""
    echo "安装方法："
    echo "  cd /Users/zs/tools/audit.vim"
    echo "  ./install_parsers_v2.sh"
fi

echo "================================"
