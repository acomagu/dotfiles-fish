set encoding=utf-8

scriptencoding utf-8

" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

if has('lua')
  NeoBundle 'shougo/neocomplcache.vim'
else
  NeoBundle 'shougo/neocomplcache'
endif

"Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Enable heavy features.
" Use camel case completion.
"let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
"let g:neocomplcache_enable_underbar_completion = 1

" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
      \ 'default' : '',
      \ 'vimshell' : $HOME.'/.vimshell_hist',
      \ 'scheme' : $HOME.'/.gosh_completions'
      \ }

" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g> neocomplcache#undo_completion()
inoremap <expr><C-l> neocomplcache#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplcache#smart_close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ?  neocomplcache#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y> neocomplcache#close_popup()
inoremap <expr><C-e> neocomplcache#cancel_popup()
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ?  neocomplcache#close_popup() : "\<Space>"

" For cursor moving in insert mode(Not recommended)
"inoremap <expr><Left> neocomplcache#close_popup() . "\<Left>"
"inoremap <expr><Right> neocomplcache#close_popup() . "\<Right>"
"inoremap <expr><Up> neocomplcache#close_popup() . "\<Up>"
"inoremap <expr><Down> neocomplcache#close_popup() . "\<Down>"
" Or set this.
"let g:neocomplcache_enable_cursor_hold_i = 1
" Or set this.
"let g:neocomplcache_enable_insert_char_pre = 1

" AutoComplPop like behavior.
"let g:neocomplcache_enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplcache_enable_auto_select = 1
"let g:neocomplcache_disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ?
"\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplcache_force_omni_patterns')
  let g:neocomplcache_force_omni_patterns = {}
endif
let g:neocomplcache_force_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_force_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_force_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" ---End of configuration of Neocomplcache---

syntax on
NeoBundle 'kien/ctrlp.vim'
NeoBundle 'flazz/vim-colorschemes'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimproc.vim', {
      \ 'build' : {
      \     'windows' : 'tools\\update-dll-mingw',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'linux' : 'make',
      \     'unix' : 'gmake',
      \    },
      \ }
NeoBundle 'romanvbabenko/rails.vim'
NeoBundle 'mattn/emmet-vim'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'terryma/vim-multiple-cursors'
set backspace=indent,eol,start
NeoBundle "osyo-manga/vim-over"
NeoBundle 'tomasr/molokai'
set t_Co=256

NeoBundle 'jonathanfilip/vim-lucius'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'AndrewRadev/splitjoin.vim'
NeoBundle 'kana/vim-submode'

NeoBundle 'kakkyz81/evervim'
let g:evervim_devtoken='S=s76:U=81e7af:E=155a60631ed:C=14e4e5502d8:P=1cd:A=en-devtoken:V=2:H=d2b080266d7101cf2a55031389157dff'

NeoBundle 'terryma/vim-expand-region'
" NeoBundle 'rhysd/clever-f.vim'
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck


" vim-submode
command! -nargs=+ -bang -complete=file Rename let pbnr=fnamemodify(bufname('%'), ':p')|exec 'f '.escape(<q-args>, ' ')|w<bang>|call delete(pbnr)duo-
call submode#enter_with('winsize', 'n', '', '<C-w>>', '<C-w>>')
call submode#enter_with('winsize', 'n', '', '<C-w><', '<C-w><')
call submode#enter_with('winsize', 'n', '', '<C-w>+', '<C-w>-')
call submode#enter_with('winsize', 'n', '', '<C-w>-', '<C-w>+')
call submode#map('winsize', 'n', '', '>', '<C-w>>')
call submode#map('winsize', 'n', '', '<', '<C-w><')
call submode#map('winsize', 'n', '', '+', '<C-w>-')
call submode#map('winsize', 'n', '', '-', '<C-w>+')

" call submode#enter_with('findlinechar', 'nv', 'e', 'f', '"V\<C-j>/\\%V".nr2char(getchar())."\<CR>"')
" map <expr> f "V\<C-j>/\\%V".nr2char(getchar())."\<CR>"
map <expr> f 'V<C-j>/\%V'.nr2char(getchar()).'<CR><Plug>(flc)'
map <Plug>(flc) a
" call submode#enter_with('findlinecha', 'n', '', '')
" call submode#map('findlinecha', 'n', '', 'n', ':echo a')
" noremap <silent> j :noh<CR>j

" vim-expand-region
vmap v <Plug>(expand_region_expand)
vmap V <Plug>(expand_region_shrink)

" evervim
nnoremap <Leader>evl :EvervimListTags<CR>
nnoremap <Leader>evs :EvervimSearchByQuery<CR>
nnoremap <Leader>ev/ :EvervimSearchByQuery<CR>

" clever-f
" nmap n <Plug>(clever-f-f)
" let g:clever_f_across_no_line = 1

let mapleader = "\<Space>"
nnoremap <Leader>w :w<CR>
nnoremap <Leader>t :tabnew<CR>
nnoremap <Leader>q ZZ
nnoremap <Leader>h ^
nnoremap <Leader>l $
nnoremap <Leader>k H
nnoremap <Leader>j L
noremap <C-j> <Esc>
noremap! <C-j> <Esc>
" nnoremap ; :

colorscheme molokai
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
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%
set shiftround
set infercase
set ignorecase
set smartcase
set incsearch
set hlsearch


" function! s:getchar()
"   let c = getchar()
"   if c =~ '^\d\+$'
"     let c = nr2char(c)
"   endif
"   return c
" endfunction

" function! Aaa()
"   let char = s:getchar()
"   /char
" endfunction
