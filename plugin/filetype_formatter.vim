""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-filetype-formatter: your favorite code formatters in Vim
" License:        MIT License
" Website:        https://github.com/pappasam/vim-filetype-formatter
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! -range=% FiletypeFormat <line1>,<line2> call filetype_formatter#format_filetype()
