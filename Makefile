install:
	# Neovim 插件安装（移除 vim 支持）
	mkdir -p ~/.config/nvim/plugin
	ln -sf ${PWD}/plugin/audit.vim ~/.config/nvim/plugin/
	# Lua 模块安装
	mkdir -p ~/.config/nvim/lua
	ln -sf ${PWD}/lua/audit.lua ~/.config/nvim/lua/
	# 二进制文件安装
	mkdir -p ~/.local/bin
	ln -sf ${PWD}/avim.py ~/.local/bin/
