""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-filetype-format: your favorite code formatters in Vim
" License:        MIT License
" Website:        https://github.com/pappasam/vim-filetype-format
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Global lookup table of Vim filetypes to system commands
if !exists('g:vim_filetype_format_commands')
  let g:vim_filetype_format_commands = {}
endif

" Only set this if you want confirmation on success
if !exists('g:vim_filetype_format_verbose')
  let g:vim_filetype_format_verbose = 0
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
function! filetype_format#format_code(system_call)
  let results_raw = execute('write !' . a:system_call)
  let results = s:strip_newlines(results_raw)
  let current_row = line('.')
  let total_rows_original = line('$')
  if !v:shell_error
    " 1. Delete last lines in buffer
    " 2. Place the script contents at the bottom of the buffer
    " 3. Go to the line above the original row
    " 4. Delete it, and everything above it
    " 5. Figure out how many rows there are in the file
    " 6. Compute the ideal new row
    " 7. Set that row, accounting for min of 0 and max of number lines
    " 8. Make the view centered to simplify viewing
    silent! undojoin
          \ | silent execute 'normal!dG'
          \ | silent put =results
          \ | silent execute current_row - 1
          \ | silent execute 'normal!dgg'
          \ | let total_rows_new = line('$')
          \ | let new_row = current_row + total_rows_new - total_rows_original
          \ | execute min([ total_rows_new, max( [0, new_row] ) ])
          \ | silent execute 'normal!z.'
    if g:vim_filetype_format_verbose
      echo 'vim-filetype-format Success:'
      echo 'Modified buffer with system call: ' . a:system_call
    endif
  else
    echo 'vim-filetype-format Error:'
    echo 'stderror message when running ' . a:system_call . ':'
    echo results
  endif
endfunction

" format_filetype: format a particular filetype with the configured command
" WrittenBy: Samuel Roeca
function! filetype_format#format_filetype()
  let global_lookup = g:vim_filetype_format_commands
  let current_filetype = &filetype
  if type(global_lookup) != v:t_dict
    echo 'vim-filetype-format Error:'
    echo 'g:vim_filetype_format_commands must be a Dictionary'
    return
  elseif !has_key(global_lookup, current_filetype)
    echo 'vim-filetype-format Error:'
    echo current_filetype . ' not configured in g:vim_filetype_format_commands'
    return
  endif
  let system_call = get(global_lookup, current_filetype, '')
  call filetype_format#format_code(system_call)
endfunction
