""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-filetype-formatter: your favorite code formatters in Vim
" License:        MIT License
" Website:        https://github.com/pappasam/vim-filetype-formatter
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Global lookup table of Vim filetypes to system commands
if !exists('g:vim_filetype_formatter_commands')
  let g:vim_filetype_formatter_commands = {}
endif

" Only set this if you want confirmation on success
if !exists('g:vim_filetype_formatter_verbose')
  let g:vim_filetype_formatter_verbose = 0
endif

" Override defaults with user preferences
let g:vim_filetype_formatter_commands = extend(
      \ g:filetype_formatter#ft#defaults,
      \ g:vim_filetype_formatter_commands)

" Commands
command! -range=% FiletypeFormat silent!
      \ let b:filetype_formatter_winview = winsaveview()
      \ | <line1>,<line2>call filetype_formatter#format_filetype()
      \ | silent call winrestview(b:filetype_formatter_winview)

command! ErrorFiletypeFormat call filetype_formatter#echo_error()
