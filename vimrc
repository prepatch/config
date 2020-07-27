" >^.^< "

syntax on
filetype plugin on
set nocompatible
set number relativenumber
set nowrap
set encoding=utf-8
set path+=**
set wildmenu
set splitbelow splitright
set hlsearch incsearch

let mapleader =" "
let maplocalleader = "\\"

" Plugins ---{{{

call plug#begin('~/.vim/plugged')

Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'tpope/vim-surround'
Plug 'junegunn/goyo.vim'

call plug#end()

" }}}

colorscheme dracula

" Statusline ---{{{

set laststatus=2

" }}}

" Mappings ---{{{

noremap <leader>j ddp
noremap <leader>k kddpk
nnoremap <leader>nh :nohlsearch<cr>
nnoremap <leader>u viwU
inoremap <c-u> <esc>viwUea
nnoremap <leader>ev :split $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>
nnoremap <leader>pb :execute "vsplit " . bufname("#")<cr>
nnoremap <leader>' viw<esc>a'<esc>bi'<esc>lel
nnoremap <leader>" viw<esc>a"<esc>bi"<esc>lel
vnoremap <leader>" <esc>a"<esc>`<i"<esc>`>2l

" Highlight trailing whitespace
nnoremap <leader>w :match Errormsg /\v +$/<cr>
nnoremap <leader>W :match none<cr>

" }}}

" Abbreviations ---{{{

iabbrev fiel file

" }}}

" FileType-specific settings ---{{{

" Vimscript file settings ---{{{

augroup filetype_vim
	autocmd!
	autocmd FileType vim setlocal foldmethod=marker
	autocmd FileType vim setlocal foldlevelstart=0
	autocmd FileType vim nnoremap <buffer> <tab> za
augroup END

" }}}

" Python file settings ---{{{

augroup filetype_python
	autocmd!
	autocmd FileType python nnoremap <buffer> <localleader>co I# <esc>
	autocmd FileType python iabbrev <buffer> df def():<left><left><left>
augroup END

" }}}

" Haskell file settings ---{{{

augroup filetype_haskell
	autocmd!
	autocmd FileType haskell nnoremap <buffer> <localleader>co I-- <esc>
augroup END

" }}}

" Text file settings ---{{{

augroup filetype_text
	autocmd!
	autocmd FileType text setlocal wrap
	autocmd FileType text setlocal nonumber norelativenumber
augroup END

" }}}

" HTML file settings ---{{{

augroup filetype_html
	autocmd!
	autocmd FileType html nnoremap <buffer> <localleader>f Vatzf
augroup END

" }}}

" Markdown file settings ---{{{

augroup filetype_markdown
	autocmd!
	" Statusline in markdown files
	autocmd FileType markdown setlocal statusline=%f	" Path to the file
	autocmd FileType markdown setlocal statusline+=%=	" Switch to the right side
	autocmd FileType markdown setlocal statusline+=%l	" Current line
	autocmd FileType markdown setlocal statusline+=/	" Separator
	autocmd FileType markdown setlocal statusline+=%L	" Total lines
	autocmd FileType markdown onoremap <buffer> ih :<c-u>execute "normal! ?^\[==,--]\\+$\r:nohlsearch\rkvg_"<cr>
	autocmd FileType markdown onoremap <buffer> ah :<c-u>execute "normal! ?^\[==,--]\\+$\r:nohlsearch\rg_vk0"<cr>
augroup END

" }}}

" }}}
