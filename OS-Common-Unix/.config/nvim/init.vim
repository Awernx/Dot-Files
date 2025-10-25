" 🅲 🅷 🅰 🅽 🅳 🅴 🆁
" ---------------------------------------------------------
" VIM editor preferences

set nocompatible    " Don't try to be Vi compatible
set number          " Show line number
set incsearch       " Search as you type - incremental
set ignorecase      " Ignore case when searching
set hlsearch        " Highlight search matches
set showmatch       " Match brackets 

" Status bar section
" ---------------------------------------------------------
set laststatus=2    " Enable status bar

set statusline =%7*[%n]%*
set statusline +=%1*%F\ %*%8*%m%r%*%1*%h%w%* "filename
set statusline +=%7*\|%*
set statusline+=%2*\ %Y: "filetype
set statusline+=%{&ff}:  "dos/unix
set statusline+=%{&fenc!=''?&fenc:&enc}\ %* "encoding
set statusline +=%7*\|%*
set statusline+=%2*\ row:%l/%*%1*%L%*%2*\ %2*\ \col:%v\ %*
set statusline +=%7*\|%*
set statusline+=%2*\ ASCII:%b\ %*  " ascii
set statusline +=%7*\|%*
