""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-filetype-formatter: your favorite code formatters in Vim
" License:        MIT License
" Website:        https://github.com/pappasam/vim-filetype-formatter
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Setup

if exists("g:loaded_filetype_formatter")
  finish
endif
let g:loaded_filetype_formatter = v:true
let s:save_cpo = &cpo
set cpo&vim

" Configuration

function! s:_prettier()
  return printf(
        \ 'npx --no-update-notifier --silent --no-install prettier --stdin-filepath="%s"',
        \ expand('%:p')
        \ )
endfunction
let s:prettier = funcref('s:_prettier')

function! s:_prettier_svelte()
  return printf(
        \ 'npx --no-update-notifier --silent --no-install prettier --plugin prettier-plugin-svelte --stdin-filepath="%s"',
        \ expand('%:p')
        \ )
endfunction
let s:prettier_svelte = funcref('s:_prettier_svelte')

function! s:_ocamlformat()
  return printf(
        \ 'ocamlformat --enable-outside-detected-project --name "%s" -',
        \ expand('%')
        \ )
endfunction
let s:ocamlformat = funcref('s:_ocamlformat')

function! s:_stylua()
  return printf(
        \ 'stylua --search-parent-directories --stdin-filepath "%s" -',
        \ expand('%')
        \ )
endfunction
let s:stylua = funcref('s:_stylua')

function! s:_styler()
  return 'Rscript --default-packages=styler ' ..
        \ '-e "options(styler.colored_print.vertical = FALSE)" ' ..
        \ '-e "options(styler.quiet = TRUE)" ' ..
        \ '-e "options(warn = -1)" ' ..
        \ '-e "style_text(' ..
        \ 'readLines(file(\"stdin\"), warn = FALSE, encoding=\"UTF-8\")' ..
        \ ')"'
endfunction
let s:styler = funcref('s:_styler')

let s:default_formatters = {
      \ 'bib': 'bibtool -q -s',
      \ 'css': s:prettier,
      \ 'go': 'gofmt',
      \ 'graphql': s:prettier,
      \ 'html': s:prettier,
      \ 'javascript': s:prettier,
      \ 'javascript.jsx': s:prettier,
      \ 'javascriptreact': s:prettier,
      \ 'jinja.html': s:prettier,
      \ 'json': s:prettier,
      \ 'jsonc': s:prettier,
      \ 'lua': s:stylua,
      \ 'markdown': s:prettier,
      \ 'markdown.mdx': s:prettier,
      \ 'mdx': s:prettier,
      \ 'nginx': 'nginxfmt -',
      \ 'ocaml': s:ocamlformat,
      \ 'prisma': s:prettier,
      \ 'python': 'black -q -',
      \ 'rust': 'rustfmt --quiet',
      \ 'scss': s:prettier,
      \ 'svelte': s:prettier_svelte,
      \ 'terraform': 'terraform fmt -',
      \ 'r': s:styler,
      \ 'toml': 'toml-sort',
      \ 'typescript': s:prettier,
      \ 'typescript.tsx': s:prettier,
      \ 'typescriptreact': s:prettier,
      \ 'yaml': s:prettier,
      \ 'yaml.docker-compose': s:prettier,
      \ }

function! s:configure_constants()
  " Only set this if you want confirmation on success
  if !exists('g:vim_filetype_formatter_verbose')
    let g:vim_filetype_formatter_verbose = v:false
  endif

  " Map weird filetypes to standard filetypes
  if !exists('g:vim_filetype_formatter_ft_maps')
    let g:vim_filetype_formatter_ft_maps = {}
  elseif type(g:vim_filetype_formatter_ft_maps) != v:t_dict
    throw 'User-configured g:vim_filetype_formatter_ft_no_defaults must be List'
  endif

  " Set filetypes for which there is no default
  if !exists('g:vim_filetype_formatter_ft_no_defaults')
    let g:vim_filetype_formatter_ft_no_defaults = []
  elseif type(g:vim_filetype_formatter_ft_no_defaults) != v:t_list
    throw 'User-configured g:vim_filetype_formatter_ft_no_defaults must be List'
  endif

  " Remove filetypes in config specified for removal specified in config
  for ft_string in g:vim_filetype_formatter_ft_no_defaults
    if has_key(s:default_formatters, ft_string)
      unlet s:default_formatters[ft_string]
    endif
  endfor

  " Global lookup table of Vim filetypes to system commands
  if !exists('g:vim_filetype_formatter_commands')
    let g:vim_filetype_formatter_commands = {}
  elseif type(g:vim_filetype_formatter_commands) != v:t_dict
    throw 'User-configured g:vim_filetype_formatter_commands must be Dict'
  endif

  " Override defaults with user preferences
  let g:vim_filetype_formatter_commands = extend(
        \ s:default_formatters,
        \ g:vim_filetype_formatter_commands)
endfunction

function! s:cmd_exists(name)
  let _exists = exists(a:name) == 2
  if _exists
    call filetype_formatter#warning(printf(
          \ 'cannot define "%s"; already defined',
          \ a:name,
          \ ))
  endif
  return _exists
endfunction

" Commands

if !s:cmd_exists(':FiletypeFormat')
  command -range=% FiletypeFormat silent!
        \ let b:filetype_formatter_winview = winsaveview()
        \ | <line1>,<line2>call filetype_formatter#format_filetype()
        \ | silent call winrestview(b:filetype_formatter_winview)
        \ | silent! normal! zO
endif

if !s:cmd_exists(':LogFiletypeFormat')
  command LogFiletypeFormat call filetype_formatter#log()
endif

if !s:cmd_exists(':DebugFiletypeFormat')
  command DebugFiletypeFormat call filetype_formatter#debug()
endif

" Finish

try
  call s:configure_constants()
catch /.*/
  call filetype_formatter#warning(printf(
        \ 'filetype_formatter: %s',
        \ v:exception,
        \ ))
finally
  " Teardown
  let &cpo = s:save_cpo
  unlet s:save_cpo
endtry
