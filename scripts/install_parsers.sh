#!/bin/bash
# Tree-sitter parsers 安装脚本 v2
# 支持需要 scanner 的语言

set -e

# 颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PARSER_DIR="$HOME/.local/share/nvim/site/parser"
WORK_DIR="/tmp/treesitter-install-v2"

# 检查编译器
if command -v clang &> /dev/null; then
    CC=clang
    CXX=clang++
elif command -v gcc &> /dev/null; then
    CC=gcc
    CXX=g++
else
    echo -e "${RED}错误：未找到编译器${NC}"
    exit 1
fi

mkdir -p "$PARSER_DIR"
mkdir -p "$WORK_DIR"

compile_simple() {
    local lang=$1
    echo -e "${BLUE}[$lang] 安装...${NC}"

    cd "$WORK_DIR"
    rm -rf "tree-sitter-$lang"

    if ! git clone "https://github.com/tree-sitter/tree-sitter-${lang}.git" --depth=1 --quiet 2>/dev/null; then
        echo -e "${YELLOW}  ⚠ 跳过 (仓库不存在)${NC}"
        return 1
    fi

    cd "tree-sitter-$lang"

    if [ -f "src/parser.c" ]; then
        $CC -o "$lang.so" -shared src/parser.c -Os -I./src 2>/dev/null && \
        mv "$lang.so" "$PARSER_DIR/" && \
        echo -e "${GREEN}  ✓ 成功${NC}" && return 0
    fi

    echo -e "${RED}  ✗ 失败${NC}"
    return 1
}

compile_with_scanner_c() {
    local lang=$1
    echo -e "${BLUE}[$lang] 安装（带 scanner.c）...${NC}"

    cd "$WORK_DIR"
    rm -rf "tree-sitter-$lang"

    if ! git clone "https://github.com/tree-sitter/tree-sitter-${lang}.git" --depth=1 --quiet 2>/dev/null; then
        echo -e "${YELLOW}  ⚠ 跳过${NC}"
        return 1
    fi

    cd "tree-sitter-$lang"

    if [ -f "src/parser.c" ] && [ -f "src/scanner.c" ]; then
        $CC -o "$lang.so" -shared src/parser.c src/scanner.c -Os -I./src 2>/dev/null && \
        mv "$lang.so" "$PARSER_DIR/" && \
        echo -e "${GREEN}  ✓ 成功${NC}" && return 0
    fi

    echo -e "${RED}  ✗ 失败${NC}"
    return 1
}

compile_with_scanner_cc() {
    local lang=$1
    local subdir=$2
    echo -e "${BLUE}[$lang] 安装（带 scanner.cc）...${NC}"

    cd "$WORK_DIR"
    rm -rf "tree-sitter-$lang"

    if ! git clone "https://github.com/tree-sitter/tree-sitter-${lang}.git" --depth=1 --quiet 2>/dev/null; then
        echo -e "${YELLOW}  ⚠ 跳过${NC}"
        return 1
    fi

    cd "tree-sitter-$lang"
    [ -n "$subdir" ] && cd "$subdir"

    if [ -f "src/parser.c" ] && [ -f "src/scanner.cc" ]; then
        $CXX -o "$lang.so" -shared src/parser.c src/scanner.cc -Os -I./src -std=c++14 2>/dev/null && \
        mv "$lang.so" "$PARSER_DIR/" && \
        echo -e "${GREEN}  ✓ 成功${NC}" && return 0
    elif [ -f "src/parser.c" ] && [ -f "src/scanner.c" ]; then
        $CC -o "$lang.so" -shared src/parser.c src/scanner.c -Os -I./src 2>/dev/null && \
        mv "$lang.so" "$PARSER_DIR/" && \
        echo -e "${GREEN}  ✓ 成功${NC}" && return 0
    fi

    echo -e "${RED}  ✗ 失败${NC}"
    return 1
}

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}Tree-sitter Parsers 安装 v2${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# 简单的（只有 parser.c）
compile_simple "java"
compile_simple "c"
compile_simple "json"
compile_simple "go"

# 带 scanner.c 的
compile_with_scanner_c "python"
compile_with_scanner_c "bash"

# 带 scanner.cc 的 (C++)
compile_with_scanner_cc "cpp"
compile_with_scanner_cc "javascript"
compile_with_scanner_cc "typescript" "typescript"
compile_with_scanner_cc "tsx" "tsx"
compile_with_scanner_cc "rust"

# 清理
rm -rf "$WORK_DIR"

echo ""
echo -e "${BLUE}================================${NC}"
echo -e "${GREEN}安装完成！${NC}"
echo ""
echo "已安装的 parsers:"
ls -1 "$PARSER_DIR" 2>/dev/null | sed 's/\.so$//' | while read -r p; do
    echo -e "  ${GREEN}✓${NC} $p"
done
echo ""
echo -e "${YELLOW}重启 Neovim 查看语法高亮效果！${NC}"
