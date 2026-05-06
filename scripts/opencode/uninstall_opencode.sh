#!/usr/bin/env bash

# =============================================================================
# OpenCode AI 插件卸载脚本
# 用于从 Neovim 配置中移除 opencode.nvim 相关配置
# =============================================================================

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检测 Neovim 配置目录
detect_nvim_config() {
    if [[ -d "$HOME/.config/nvim" ]]; then
        echo "$HOME/.config/nvim"
    elif [[ -d "$HOME/.nvim" ]]; then
        echo "$HOME/.nvim"
    else
        return 1
    fi
}

# 检测配置文件
detect_config_file() {
    local nvim_config_dir="$1"

    if [[ -f "$nvim_config_dir/init.lua" ]]; then
        echo "$nvim_config_dir/init.lua"
    elif [[ -f "$nvim_config_dir/init.vim" ]]; then
        echo "$nvim_config_dir/init.vim"
    else
        return 1
    fi
}

# 备份配置文件
backup_config() {
    local config_file="$1"
    local backup_file="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"

    cp "$config_file" "$backup_file"
    log_success "配置文件已备份到: $backup_file"
    echo "$backup_file"
}

# 移除 OpenCode 配置
remove_opencode_config() {
    local config_file="$1"
    local temp_file=$(mktemp)

    # 移除由 install_opencode.sh 自动添加的所有内容
    awk '
        /由 install_opencode\.sh 自动添加/ {
            # 找到开始标记
            in_block = 1
            # 记录当前块的起始位置
            block_start = NR
            next
        }
        in_block {
            # 检查是否到达块结束（空行后的新配置或文件结束）
            if (/^-- =============================================================================/ && NR > block_start + 5) {
                # 保持读取直到块结束
                getline
                if ($0 ~ /^$/ || $0 !~ /^--/) {
                    in_block = 0
                }
            }
            # 跳过块内的所有行
            next
        }
        !in_block {
            print
        }
    ' "$config_file" > "$temp_file"

    # 移除 opencode.nvim 插件声明
    grep -v "opencode.nvim\|audit.opencode" "$temp_file" > "$temp_file.2" || true
    mv "$temp_file.2" "$temp_file"

    # 移除空白行（清理）
    awk 'NF > 0 || prev_nf > 0 { print; prev_nf = NF }' "$temp_file" > "$config_file"

    rm -f "$temp_file"
    log_success "已移除 OpenCode 配置"
}

# 主函数
main() {
    echo "=========================================="
    echo "  OpenCode AI 插件卸载脚本"
    echo "=========================================="
    echo ""

    # 1. 检测 Neovim 配置目录
    log_info "检测 Neovim 配置目录..."
    nvim_config_dir=$(detect_nvim_config)

    if [[ -z "$nvim_config_dir" ]]; then
        log_error "找不到 Neovim 配置目录"
        exit 1
    fi

    log_success "找到配置目录: $nvim_config_dir"

    # 2. 检测配置文件
    log_info "检测配置文件..."
    config_file=$(detect_config_file "$nvim_config_dir")

    if [[ -z "$config_file" ]]; then
        log_error "找不到配置文件"
        exit 1
    fi

    log_success "配置文件: $config_file"

    # 3. 检查是否安装了 OpenCode
    if ! grep -q "opencode.nvim\|audit.opencode" "$config_file" 2>/dev/null; then
        log_warning "配置文件中没有找到 OpenCode 配置"
        exit 0
    fi

    # 4. 确认卸载
    log_warning "即将从配置文件中移除 OpenCode 相关配置"
    read -p "是否继续？(y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "卸载已取消"
        exit 0
    fi

    # 5. 备份配置文件
    log_info "备份配置文件..."
    backup_file=$(backup_config "$config_file")

    # 6. 移除配置
    log_info "移除 OpenCode 配置..."
    remove_opencode_config "$config_file" || {
        log_error "移除配置失败"
        log_info "恢复备份..."
        cp "$backup_file" "$config_file"
        exit 1
    }

    # 7. 完成
    echo ""
    echo "=========================================="
    log_success "卸载完成！"
    echo "=========================================="
    echo ""
    echo "下一步："
    echo "  1. 重启 Neovim 或运行 :source $config_file"
    echo "  2. 如果使用插件管理器，可能需要手动移除插件："
    echo "     - lazy.nvim: :Lazy clean"
    echo "     - packer.nvim: :PackerClean"
    echo "     - vim-plug: :PlugClean"
    echo ""
    echo "配置文件备份: $backup_file"
    echo "如需恢复，运行: cp $backup_file $config_file"
    echo ""
}

# 运行主函数
main "$@"
