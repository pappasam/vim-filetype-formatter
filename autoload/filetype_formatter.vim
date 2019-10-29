""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-filetype-formatter: your favorite code formatters in Vim
" License:        MIT License
" Website:        https://github.com/pappasam/vim-filetype-formatter
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:strip_newlines(instring)
  " Strip newlines from a string
  return substitute(a:instring, '\v^\n*(.{-})\n*$', '\1', '')
endfunction

function! s:parse_config(global_lookup)
  if !has_key(a:global_lookup, &filetype)
    throw '"' . &filetype .
          \ '" not configured in g:vim_filetype_formatter_commands'
  endif
  return get(a:global_lookup, &filetype, '')
endfunction

" parse_call: parse the system call, determining specifics of configuration
" WrittenBy: Samuel Roeca
" Parameters:
"   syscall_config: String | Function[Integer, Integer] | Function[]
"   first_line: int : the first line for formatting
"   last_line: int : the last line for formatting
" Returns: Dict[system_call: String, lines_specified: Integer]
"
" Note: this function is a little ugly. It's really hard to test Vimscript
" functions for number of accepted parameters. Functions accept more arguments
" than configured, but fail if you don't pass them at least the number of
" required arguments.
function! s:parse_call(Syscall_config, first_line, last_line)
  let t_config_system_call = type(a:Syscall_config)
  if t_config_system_call == v:t_string
    let result = {
          \ 'system_call': a:Syscall_config,
          \ 'lines_specified': 0,
          \ }
  elseif t_config_system_call == v:t_func
    try
      let result = {
            \ 'system_call': a:Syscall_config(),
            \ 'lines_specified': 0,
            \ }
    catch /.*/
      try
        " test if function accepts 1 argument
        let _whatever = a:Syscall_config(1)
        let bad_function_one_argument = v:true
      catch /.*/
        let bad_function_one_argument = v:false
      endtry
      if bad_function_one_argument == v:true
        throw 'Formatter function only has 1 argument. Must have 0 or 2 args'
      endif

      try
        let result = {
              \ 'system_call': a:Syscall_config(a:first_line, a:last_line),
              \ 'lines_specified': 1,
              \ }
      catch /.*/
        throw 'Formatter function must take exactly 0, or 2, arguments'
      endtry
    endtry
  else
    throw 'Formatter value is neither a String nor a function'
  endif
  if type(result['system_call']) != v:t_string
    throw '"' . &filetype .
          \ '" is configured as neither a function nor a string'
          \ ' in g:vim_filetype_formatter_commands'
  endif
  " Make sure pipelines (eg, 'x - | y - | z -') fail immediately
  let result.system_call = 'set -Eeuo pipefail; ' . result.system_call
  return result
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
  let stdin = join(getline(a:first_line, a:last_line), "\n")
  let results_raw = system(a:system_call, stdin)
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
  let stdin = join(getline(1, '$'), "\n")
  let results_raw = system(a:system_call, stdin)
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
  else
    throw '"' . a:system_call . "\":\n" . results
  endif
endfunction

" format_filetype: format a particular filetype with the configured command
" WrittenBy: Samuel Roeca
" Parameters: firstline AND lastline: int : from range command
function! filetype_formatter#format_filetype() range
  try
    " Temporarily change shell. This will be reverted in the finally block
    let user_shell = &shell
    set shell=/bin/bash

    " Note: below must begin with capital letter
    let Config_system_call = s:parse_config(g:vim_filetype_formatter_commands)
    let parser = s:parse_call(Config_system_call, a:firstline, a:lastline)
    if a:firstline == 1 && a:lastline == line('$')
      " The entire buffer is selected, hence we use the entire file
      call s:format_code_file(parser.system_call)
    elseif parser.lines_specified == 1
      " Lines were specifically specified through function arguments.
      " The specific lines to be updated are handled by the formatter itself
      call s:format_code_file(parser.system_call)
    else
      call s:format_code_range(parser.system_call, a:firstline, a:lastline)
    endif
    if g:vim_filetype_formatter_verbose
      echo 'Success! ' . '"' . parser.system_call . '"'
    endif
    let b:vim_filetype_formatter_log =
          \ 'Success! "' . parser.system_call . '" ran successfully'
  catch /.*/
    echo 'Error! Run ":LogFiletypeFormat" for details'
    let b:vim_filetype_formatter_log = "Error! " . v:exception
    return
  finally
    " Revert shell to what it was before.
    execute 'set shell=' . user_shell
  endtry
endfunction

" echo_log: print the full console output from the most-recent formatter run
" in this buffer
" WrittenBy: Samuel Roeca
function! filetype_formatter#echo_log()
  if !exists('b:vim_filetype_formatter_log')
    echo 'FiletypeFormat has not been tried on this buffer'
    return
  endif
  echo 'vim-filetype-formatter: ' . b:vim_filetype_formatter_log
endfunction
