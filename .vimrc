scriptencoding utf-8

" dein.vim
if &compatible
  set nocompatible
endif
set runtimepath^=/home/yuki/.config/nvim/dein.vim/repos/github.com/Shougo/dein.vim
call dein#begin(expand('/home/yuki/.config/nvim/dein.vim'))
call dein#add('Shougo/dein.vim')

call dein#add('kien/ctrlp.vim')
call dein#add('tomtom/tcomment_vim')
call dein#add('terryma/vim-multiple-cursors')
call dein#add('tomasr/molokai')
call dein#add('AndrewRadev/splitjoin.vim')
call dein#add('kana/vim-submode')
call dein#add('plasticboy/vim-markdown')
call dein#add('koron/imcsc-vim')
call dein#add('Shougo/neomru.vim')
call dein#add('Shougo/unite.vim')
call dein#add('Shougo/unite-outline')
call dein#add('Shougo/deoplete.nvim')
call dein#add('fatih/vim-go')
call dein#add('zchee/deoplete-go', {'build': 'make'})
  call dein#add('nsf/gocode')
call dein#add('benekastah/neomake')

call dein#end()
filetype plugin indent on
if dein#check_install()
  call dein#install()
endif

let g:python3_host_prog  = '/usr/bin/python3'

" neomake
autocmd! BufWritePost * Neomake

" vim-go
let g:go_fmt_command = "goimports"
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_term_enabled = 1
let g:go_highlight_build_constraints = 1

" deoplete-go
let g:deoplete#sources#go#align_class = 1
let g:deoplete#sources#go#sort_class = ['package', 'func', 'type', 'var', 'const']
let g:deoplete#sources#go#package_dot = 1

" set key of <Leader>
let mapleader = "\<Space>"

" deoplete
if dein#is_sourced('deoplete.nvim')
  let g:deoplete#enable_at_startup = 1

  let g:acp_enableAtStartup = 0
  let g:deoplete#enable_at_startup = 1
  let g:deoplete#enable_smart_case = 1
  let g:deoplete#sources#syntax#min_keyword_length = 3
  let g:deoplete#lock_buffer_name_pattern = '\*ku\*'
  let g:deoplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
  \ }
  if !exists('g:deoplete_keyword_patterns')
      let g:deoplete#keyword_patterns = {}
  endif
  let g:deoplete#keyword_patterns['default'] = '\h\w*'
  inoremap <expr><C-g>     deoplete#undo_completion()
  inoremap <expr><C-l>     deoplete#complete_common_string()
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function()
    return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  endfunction
  inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  if !exists('g:deoplete#sources#omni#input_patterns')
    let g:deoplete#sources#omni#input_patterns = {}
  endif
  let g:deoplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
endif

" vim-submode
let g:submode_keep_leaving_key = 1
let g:submode_timeout = 0
command! -nargs=+ -bang -complete=file Rename let pbnr=fnamemodify(bufname('%'), ':p')|exec 'f '.escape(<q-args>, ' ')|w<bang>|call delete(pbnr)duo-
call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>-')
call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>+')
call submode#map('winsize', 'n', '', '>', '<C-w>>')
call submode#map('winsize', 'n', '', '<', '<C-w><')
call submode#map('winsize', 'n', '', '+', '<C-w>-')
call submode#map('winsize', 'n', '', '-', '<C-w>+')

" extension of f-function
nmap <expr> f 'lv$<Esc>/\%V['.nr2char(getchar()).']<CR><Plug>(flc)'
nmap <expr> F 'hv0<Esc>?\%V['.nr2char(getchar()).']<CR><Plug>(flc)'
call submode#enter_with('flc', 'n', '', '<Plug>(flc)', ':autocmd flc InsertEnter * noh<CR>')
call submode#map('flc', 'n', '', 'n', 'n')
call submode#map('flc', 'n', '', 'N', 'N')

" Unite
nnoremap <Leader>u :Unite<CR>
nnoremap <Leader>p :Unite file_rec<CR>
let g:unite_enable_start_insert=1

" other custom keymaps

nnoremap <Leader>w :w<CR>
nnoremap <Leader>t :tabnew<CR>
nnoremap <Leader>q ZZ
nnoremap <Leader>h 60h
nnoremap <Leader>l 60l
nnoremap <Leader>k 15k
nnoremap <Leader>j 15j
noremap <C-j> <Esc>:noh<CR>
noremap! <C-j> <Esc>:noh<CR>
tnoremap <C-j> <C-\><C-n>

" nvim
colorscheme molokai
syntax on
set t_Co=256
set backspace=indent,eol,start
set fileencoding=utf-8
set scrolloff=5
set noswapfile
set nowritebackup
set nobackup
set number
set showmatch matchtime=1
set autoindent
set expandtab
set shiftwidth=2
set smartindent
set backspace=indent
set vb t_vb=
set novisualbell
set clipboard+=unnamed
set clipboard=unnamed
set list
set ruler
set matchpairs& matchpairs+=<:>
set showmatch
set matchtime=3
set wrap
set textwidth=0
set listchars=tab:»\ ,trail:-,extends:»,precedes:«,nbsp:%
set tabstop=2
set shiftround
set infercase
set ignorecase
set smartcase
set incsearch
set hlsearch
set ambiwidth=double

" configs of auto insertion list prefix on markdown files
augroup config
  autocmd!
  autocmd FileType markdown inoremap <buffer><expr> <CR> (getline('.') =~ '^\s*-\s') ? '<CR>- ' : '<CR>'
  autocmd FileType markdown nnoremap <buffer><expr> o (getline('.') =~ '^\s*-\s') ? 'o- ' : 'o'
  autocmd FileType markdown inoremap <buffer><expr> <CR> (getline('.') =~ '^\s*\*\s') ? '<CR>* ' : '<CR>'
  autocmd FileType markdown nnoremap <buffer><expr> o (getline('.') =~ '^\s*\*\s') ? 'o* ' : 'o'
  autocmd BufNewFile,BufRead *.es6 set filetype=javascript
augroup END

" config of vim -b option. it enables read binary for vim
augroup BinaryXXD
  autocmd!
  autocmd BufReadPre  *.bin let &binary =1
  autocmd BufReadPost * if &binary | silent %!xxd -g 1
  autocmd BufReadPost * set ft=xxd | endif
  autocmd BufWritePre * if &binary | %!xxd -r | endif
  autocmd BufWritePost * if &binary | silent %!xxd -g 1
  autocmd BufWritePost * set nomod | endif
augroup END
