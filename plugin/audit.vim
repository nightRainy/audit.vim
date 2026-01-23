" =============================================================================
" audit.nvim - 轻量级代码审计工具（仅支持 Neovim）
" 需要: Neovim 0.5+
" =============================================================================

" Neovim 版本检查
if !has('nvim')
  echohl ErrorMsg
  echo "audit.vim: 此版本仅支持 Neovim。请使用旧版本或安装 Neovim。"
  echohl None
  finish
endif

" 辅助函数 --- {{{
function! VisualSelectedText()
  let l:vm = visualmode()
  let l:bak = @@
  if l:vm ==# 'v'
    normal! `<v`>y
  elseif l:vm ==# 'char'
    normal! `[v`]y
  endif
  let l:text = @@
  let @@ = l:bak
  return l:text
endfunction

function! DoExecute(prefix, text, escape)
  let l:text = a:text
  if a:escape == 1
    " quote with ''
    let l:text = shellescape(a:text)
  elseif a:escape == 2
    " regex escape
    let l:text = escape(a:text, '^$()[]{}.*?\')
  elseif a:escape == 3
    " both
    let l:text = escape(a:text, '^$()[]{}.*?\')
    let l:text = shellescape(l:text)
  endif
  execute a:prefix . " " . l:text
endfunction
" }}}

" 通用选项 --- {{{
nnoremap [[ [{
nnoremap ]] ]}

" ReadOnly Mode
if $AVIM_SRC != ""
  augroup smartchdir
      " disable smart directory changing
      autocmd!
      set noautochdir
  augroup END

  " 允许特殊 buffer（如 healthcheck）可修改
  augroup special_buffers
      autocmd!
      " 在 buffer 创建时就检查并设置特殊 buffer 为可修改
      autocmd BufNew,BufNewFile,BufReadPre *
            \ if expand('<afile>') =~# 'health://' ||
            \    &buftype ==# 'nofile' ||
            \    &buftype ==# 'help' ||
            \    &buftype ==# 'quickfix' ||
            \    &buftype ==# 'terminal' |
            \   setlocal modifiable noreadonly |
            \ endif
      " checkhealth buffer 必须可修改
      autocmd FileType checkhealth setlocal modifiable noreadonly
      " quickfix 和其他特殊窗口也应该可修改
      autocmd FileType qf setlocal modifiable noreadonly
      " help、man 等内置文档也应该可以正常浏览
      autocmd FileType help,man setlocal modifiable noreadonly
      " 插件窗口（如 aerial、telescope 等）
      autocmd BufWinEnter * if &buftype != '' && &buftype != 'acwrite' | setlocal modifiable noreadonly | endif
  augroup END
  " remap JK to navigate quickfix
  nnoremap J :cnext<cr>
  nnoremap K :cprev<cr>
  nnoremap H :colder<cr>
  nnoremap L :cnewer<cr>

  " remap movement shortcuts
  nnoremap i 5k
  nnoremap o 5j
  nnoremap O <Nop>
  nnoremap u 5<c-y>
  nnoremap d 5<c-e>
  nnoremap <silent><expr> c (&hls && v:hlsearch ? ':nohlsearch' : ':set hlsearch').'<cr>'
  nnoremap x <Nop>
  nnoremap p <Nop>
  nnoremap a :bprev<CR>
  nnoremap s :bnext<CR>
  nnoremap S <Nop>
  nnoremap B :Buffers<CR>

  let g:asyncrun_root = $AVIM_SRC
  lcd $AVIM_SRC
endif

if $AVIM_BOOKMARK != ""
  let g:bookmark_auto_save_file = $AVIM_BOOKMARK
endif
" }}}

" asyncrun.vim shortcuts --- {{{
" 延迟检查 AsyncRun，避免过早的警告信息
function! s:SetupAsyncRun()
  if exists(':AsyncRun')
  " 自动打开 quickfix 窗口显示 AsyncRun 结果
  let g:asyncrun_open = 12
  nnoremap <leader>q :call asyncrun#quickfix_toggle(12)<CR>
  command! -nargs=+ -complete=tag Grep AsyncRun -cwd=<root> rg "-n" <args>

  " Find 命令：使用 find 查找文件
  " 用法: :Find -name "*.java" 或 :Find -iname "*main*"
  command! -nargs=+ -complete=file Find AsyncRun -errorformat=\%f -cwd=<root> find . -type f <args>

  " FindName 命令：简化的按文件名查找
  " 用法: :FindName MainActivity.java
  command! -nargs=1 -complete=file FindName AsyncRun -errorformat=\%f -cwd=<root> find . -type f -name <args>

  " FindPattern 命令：使用通配符查找（不区分大小写）
  " 用法: :FindPattern "*activity*"
  command! -nargs=1 FindPattern AsyncRun -errorformat=\%f -cwd=<root> find . -type f -iname <args>

  if has('win32') || has('win64')
    nnoremap <silent><F2> :AsyncRun! -cwd=<root> findstr /n /s /C:"<C-R><C-W>"
          \ "\%CD\%\*.h" "\%CD\%\*.c*" <cr>
  else
    " 使用 AsyncRun 执行异步搜索
    nnoremap <silent><F2> :AsyncRun! -errorformat=\%f:\%l:\%c:\%m -cwd=<root> rg --vimgrep -w <C-R><C-W> <cr>
    vnoremap <silent><F2> :call DoExecute("AsyncRun! -errorformat=\\%f:\\%l:\\%c:\\%m -cwd=<root> rg --vimgrep ", VisualSelectedText(), 3)<cr>
    " 搜索方法定义
    nnoremap <silent><F3> :AsyncRun! -errorformat=\%f:\%l:\%c:\%m -cwd=<root> rg --vimgrep " <C-R><C-W>\(.*\) .*\{" <cr>
  endif
  else
    " AsyncRun 不可用，使用同步命令作为回退
    " 只在真正需要时才显示警告（用户手动调用时）
    nnoremap <leader>q :copen 12<CR>
    command! -nargs=+ -complete=tag Grep execute 'silent grep! -n' <q-args> '.' | copen

    if has('win32') || has('win64')
      nnoremap <silent><F2> :execute 'silent grep! -n -r' shellescape(expand('<cword>')) '.'<CR>:copen<CR>
    else
      " 使用同步 grep 命令
      nnoremap <silent><F2> :execute 'silent grep! --vimgrep -w' shellescape(expand('<cword>')) '.'<CR>:copen<CR>
      vnoremap <silent><F2> :execute 'silent grep! --vimgrep' shellescape(VisualSelectedText()) '.'<CR>:copen<CR>
      " 搜索方法定义
      nnoremap <silent><F3> :execute 'silent grep! --vimgrep' shellescape(expand('<cword>') . '(.*) .*{') '.'<CR>:copen<CR>
    endif

    " 设置 grepprg 为 ripgrep
    if executable('rg')
      set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
      set grepformat=%f:%l:%c:%m
    endif
  endif
endfunction

" 延迟到插件加载完成后再配置
augroup audit_asyncrun_setup
  autocmd!
  autocmd VimEnter * call s:SetupAsyncRun()
augroup END
""" }}}

" ctags/aerial.nvim 配置 --- {{{
if $AVIM_TAGS != ""
  set tags=$AVIM_TAGS
else
  set tags=.tags; " 向上搜索 ctags 文件
endif

" 使用 aerial.nvim 作为符号查看器
" 插件地址: https://github.com/stevearc/aerial.nvim
" 需要在 init.lua 中配置 aerial.setup()
if exists(':AerialToggle')
  nnoremap <leader>o :AerialToggle<CR>
else
  nnoremap <leader>o :echohl WarningMsg \| echo "请安装 aerial.nvim" \| echohl None<CR>
endif
" }}}

" LSP 符号导航快捷键（替代 cscope） --- {{{
" 这些快捷键使用 Neovim 内置 LSP
" 需要在 init.lua 中设置 nvim-lspconfig

" 符号导航
nnoremap <leader>fs <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <leader>fg <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <leader>fc <cmd>lua vim.lsp.buf.incoming_calls()<CR>
nnoremap <leader>ft <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <leader>fe :Grep <C-R>=expand("<cword>")<CR><CR>
nnoremap <leader>fd <cmd>lua vim.lsp.buf.outgoing_calls()<CR>

" 额外的 LSP 功能
nnoremap <leader>h <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>rn <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <leader>ca <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>di <cmd>lua vim.diagnostic.open_float()<CR>
nnoremap [d <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap ]d <cmd>lua vim.diagnostic.goto_next()<CR>
" }}}

" fzf.vim shortcuts --- {{{
nnoremap <leader>ff :call DoExecute("FZF -1 -q", expand("<cword>"), 0)<cr>
vnoremap <leader>ff :call DoExecute("FZF -1 -q", VisualSelectedText(), 0)<cr>
nnoremap <leader>r :call DoExecute("RG", expand("<cword>"), 0)<cr>
vnoremap <leader>r :call DoExecute("RG", VisualSelectedText(), 2)<cr>
""" }}}

" OpenCode AI 集成 --- {{{
" OpenCode AI 编程助手的快捷键和命令由 lua/audit/opencode.lua 配置
" 默认快捷键:
"   <C-a>  - 询问 AI（普通模式和可视模式）
"   <C-x>  - 选择执行动作
"   <C-.>  - 切换 opencode 终端
"
" 可用命令:
"   :OpencodeExplainDiagnostics  - 解释诊断信息
"   :OpencodeFix                 - 修复诊断问题
"   :OpencodeExplain             - 解释代码
"   :OpencodeReview              - 代码审查
"   :OpencodeOptimize            - 优化代码
"   :OpencodeDocument            - 添加文档
"   :OpencodeTest                - 添加测试
"   :OpencodeAsk [prompt]        - 自由提问
"
" 在 init.lua 中启用 OpenCode:
"   local opencode_config = require('audit.opencode')
"   if opencode_config.check_cli() then
"     opencode_config.setup()
"     opencode_config.setup_commands()
"   end
""" }}}
