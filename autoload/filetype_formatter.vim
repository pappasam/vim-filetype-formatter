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

function! s:parse_config(global_lookup)
  if type(a:global_lookup) != v:t_dict
    throw 'g:vim_filetype_formatter_commands must be a Dictionary'
  elseif !has_key(a:global_lookup, &filetype)
    throw '"' . &filetype .
          \ '" not configured in g:vim_filetype_formatter_commands'
  endif
  return get(a:global_lookup, &filetype, '')
endfunction

" format_code_range: format buffer range with system call
" WrittenBy: Samuel Roeca
" Parameters:
"   system_call: str : the string value of the system call to be performed.
"     Must take input from stdin and read input to stdout.
"   first_line: int : the first line for formatting
"   last_line: int : the last line for formatting
function! s:format_code_range(
      \ system_call, first_line, last_line)
  let results_raw = execute(
        \ a:first_line . ',' . a:last_line . 'write !' . a:system_call)
  let results = s:strip_newlines(results_raw)
  if !v:shell_error
    if a:first_line != a:last_line
      " Delete the relevant part of buffer if more than 1 line as input
      silent execute a:first_line . ',' . (a:last_line - 1) . 'delete'
    endif

    " Place the script contents in that buffer
    silent put =results

    " Delete the first line from range; it's unnecessary
    silent execute a:first_line . 'delete'
  else
    throw 'System call:' . a:system_call . "\n" . results
  endif
endfunction

" format_code_file: format entire buffer with system call
" WrittenBy: Samuel Roeca
" Inspired By: https://github.com/IanConnolly/rust.vim/blob/15081c82c103aa2dbd9509e3422a5e6076c68776/autoload/rustfmt.vim
" Parameters:
"   system_call: str : the string value of the system call to be performed.
"     Must take input from stdin and read input to stdout.
function! s:format_code_file(system_call)
  let results_raw = execute('write !' . a:system_call)
  let results = s:strip_newlines(results_raw)
  if !v:shell_error
    " remove undo point caused via BufWritePre
    try | silent undojoin | catch | endtry

    " Replace current file with temp file, then reload buffer. Finally, make
    " sure new file has same Unix permissions as old file
    let tempfile = tempname()
    call writefile(split(results, '\n'), tempfile)
    call system('chmod --reference=' . expand('%') . ' ' . tempfile)
    call rename(tempfile, expand('%'))
    silent edit!

    " Custom filetype overrides will be ignored in new file. This sets the
    " filetype and syntax again explicitly to preserve user's custom overrides
    let &syntax = &syntax
    let &filetype = &filetype
  else
    throw '"' . a:system_call . "\":\n" . results
  endif
endfunction

" format_filetype: format a particular filetype with the configured command
" WrittenBy: Samuel Roeca
" Parameters: firstline AND lastline: int : from range command
function! filetype_formatter#format_filetype() range
  try
    " Note: below must begin with capital letter
    let Config_system_call = s:parse_config(g:vim_filetype_formatter_commands)
    let t_config_system_call = type(Config_system_call)
    if t_config_system_call == v:t_func
      let system_call = Config_system_call(a:firstline, a:lastline)
    else
      let system_call = Config_system_call
    endif
    if type(system_call) != v:t_string
      throw '"' . &filetype .
            \ '" is configured as neither a function nor a string'
            \ ' in g:vim_filetype_formatter_commands'
    endif

    if a:firstline == 1 && a:lastline == line('$')
      " The entire buffer is selected, hence we use the entire file
      call s:format_code_file(system_call)
    elseif t_config_system_call == v:t_func
      " When configuring with function, it takes range arguments
      " The specific lines to be updated are handled by the formatter itself
      call s:format_code_file(system_call)
    else
      call s:format_code_range(system_call, a:firstline, a:lastline)
    endif
    let b:vim_filetype_formatter_error =
          \ 'No recent error! Previous command "'
          \ . system_call . '" ran successfully'
  catch /.*/
    echo 'Error! Run ":ErrorFiletypeFormat" for details'
    let b:vim_filetype_formatter_error = v:exception
    return
  endtry
  if g:vim_filetype_formatter_verbose
    echo 'Successfully ran ' . '"' . system_call . '"'
  endif
endfunction

" get_error: print the error message to the Vim console
" WrittenBy: Samuel Roeca
function! filetype_formatter#echo_error()
  if !exists('b:vim_filetype_formatter_error')
    echo 'No recent errors! FiletypeFormat has not been tried on this buffer'
    return
  endif
  echo 'vim-filetype-formatter: ' . b:vim_filetype_formatter_error
endfunction
