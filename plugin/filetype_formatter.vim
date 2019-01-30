""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-filetype-format: your favorite code formatters in Vim
" License:        MIT License
" Website:        https://github.com/pappasam/vim-filetype-format
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! -buffer FiletypeFormat call filetype_format#format_filetype()
