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
" 检查 AsyncRun 是否可用
if exists(':AsyncRun')
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
  echohl WarningMsg
  echo "audit.vim: AsyncRun 插件未安装，使用同步搜索（可能会阻塞）"
  echohl None

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
