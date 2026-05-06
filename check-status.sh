#!/bin/bash
# 快速检查脚本 - 检查插件和 parser 状态
echo "检查插件状态..."
./scripts/check/check_plugins.sh
echo ""
echo "检查 parser 状态..."
./scripts/check/check_parser.sh
