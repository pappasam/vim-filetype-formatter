""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-filetype-formatter: your favorite code formatters in Vim
" License:        MIT License
" Website:        https://github.com/pappasam/vim-filetype-formatter
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! -range=% FiletypeFormat silent!
      \ let b:filetype_formatter_winview = winsaveview()
      \ | <line1>,<line2>call filetype_formatter#format_filetype()
      \ | silent call winrestview(b:filetype_formatter_winview)

command! ErrorFiletypeFormat call filetype_formatter#echo_error()
