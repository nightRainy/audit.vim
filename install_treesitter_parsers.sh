#!/bin/bash
# 安装 Tree-sitter parsers 脚本

echo "================================"
echo "Installing Tree-sitter Parsers"
echo "================================"

echo ""
echo "Step 1: Syncing plugins..."
nvim --headless "+Lazy! sync" "+qa" 2>&1 | grep -v "^$"

echo ""
echo "Step 2: Installing Java parser..."
nvim --headless "+TSInstallSync java" "+qa" 2>&1

echo ""
echo "Step 3: Installing other parsers..."
nvim --headless "+TSInstallSync kotlin c cpp python lua bash json yaml xml" "+qa" 2>&1

echo ""
echo "Step 4: Checking installed parsers..."
nvim --headless "+TSInstallInfo" "+sleep 2" "+qa!" 2>&1 | grep -A 50 "TreeSitter"

echo ""
echo "✓ Installation complete!"
echo ""
echo "Now restart Neovim to see Java syntax highlighting."
