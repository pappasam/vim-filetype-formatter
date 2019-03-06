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

function! s:strip_newlines(instring)
  " Strip newlines from a string
  return substitute(a:instring, '\v^\n*(.{-})\n*$', '\1', '')
endfunction

" format_code: format entire buffer with system call
" WrittenBy: Samuel Roeca
" Parameters:
"   system_call: str :
"     the string value of the system call to be performed.
"     Must take input from stdin and read input to stdout.
function! filetype_formatter#format_code(system_call, first_line, last_line)
  let results_raw = execute(
        \ a:first_line . ',' . a:last_line . 'write !' . a:system_call)
  let results = s:strip_newlines(results_raw)
  if !v:shell_error
    " 1. Delete the relevant part of buffer
    " 2. Place the script contents in that buffer
    " 3. Delete the first line from range; it's unnecessary
    silent! undojoin
          \ | silent execute a:first_line . ',' a:last_line - 1 . 'delete'
          \ | silent put =results
          \ | silent execute a:first_line . 'delete'

    if g:vim_filetype_formatter_verbose
      echo 'vim-filetype-format: Success!'
      echo 'Modified buffer with system call: ' . a:system_call
    endif
  else
    echo 'vim-filetype-format: Error :('
    echo 'stderror message when running ' . a:system_call . ':'
    echo results
  endif
endfunction

" format_filetype: format a particular filetype with the configured command
" WrittenBy: Samuel Roeca
function! filetype_formatter#format_filetype() range
  let global_lookup = g:vim_filetype_formatter_commands
  let current_filetype = &filetype
  if type(global_lookup) != v:t_dict
    echo 'vim-filetype-format: Error :('
    echo 'g:vim_filetype_formatter_commands must be a Dictionary'
    return
  elseif !has_key(global_lookup, current_filetype)
    echo 'vim-filetype-format: Error:('
    echo current_filetype .
          \ ' not configured in g:vim_filetype_formatter_commands'
    return
  endif
  let system_call = get(global_lookup, current_filetype, '')
  let winview = winsaveview()
  call filetype_formatter#format_code(system_call, a:firstline, a:lastline)
  silent call winrestview(winview)
endfunction
