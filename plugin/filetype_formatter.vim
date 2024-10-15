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

" Use vim's built-in commands.
" 1. = (the vimscript_builtin)
" 2. Replace all instances of multiple blank lines, shortening to a single
function! s:vimscript_builtin(startline, endline)
  return printf(
        \ ':silent! execute "normal! %igg=%igg" | silent! %i,%iglobal/^\_$\n\_^$/de',
        \ a:startline, a:endline,
        \ a:startline, a:endline
        \ )
endfunction

function! s:prettier(startline, endline)
  let startpos = line2byte(a:startline) - 1
  let endpos = line2byte(a:endline + 1) - 1
  return printf(
        \ 'prettier --range-start=%i --range-end=%i --stdin-filepath="%s"',
        \ startpos,
        \ endpos,
        \ expand('%:p')
        \ )
endfunction
function! s:prettier_svelte()
  " Range not currently supported: <https://github.com/sveltejs/prettier-plugin-svelte/issues/233>
  return printf(
        \ 'prettier --plugin prettier-plugin-svelte --stdin-filepath="%s"',
        \ expand('%:p')
        \ )
endfunction
function! s:prettier_prisma()
  " Range does not currently appear to be supported
  return printf(
        \ 'prettier --plugin prettier-plugin-prisma --stdin-filepath="%s"',
        \ expand('%:p')
        \ )
endfunction
function! s:prettier_no_explicit_range()
  return printf(
        \ 'prettier --stdin-filepath="%s"',
        \ expand('%:p')
        \ )
endfunction
function! s:ocamlformat()
  return printf(
        \ 'ocamlformat --enable-outside-detected-project --name "%s" -',
        \ expand('%')
        \ )
endfunction
function s:ruff()
  return printf(
        \ 'ruff check --unsafe-fixes -q --fix-only --stdin-filename="%1$s" - | ' ..
        \ 'ruff format -q --stdin-filename="%1$s" -',
        \ expand('%:p'))
endfunction
function! s:shfmt()
  return printf(
        \ 'shfmt --indent %i --filename "%s"',
        \ &expandtab == 1 ? &softtabstop : 0,
        \ expand('%:p')
        \ )
endfunction
function! s:stylua(startline, endline)
  " Range formatting requires complete statement to be selected.
  let startpos = line2byte(a:startline) - 1
  let endpos = line2byte(a:endline + 1) - 1
  return printf(
        \ 'stylua --search-parent-directories --range-start %i --range-end %i --stdin-filepath "%s" -',
        \ startpos,
        \ endpos,
        \ expand('%')
        \ )
endfunction
function! s:styler()
  return 'Rscript --default-packages=styler ' ..
        \ '-e "options(styler.colored_print.vertical = FALSE)" ' ..
        \ '-e "options(styler.quiet = TRUE)" ' ..
        \ '-e "options(warn = -1)" ' ..
        \ '-e "style_text(' ..
        \ 'readLines(file(\"stdin\"), warn = FALSE, encoding=\"UTF-8\")' ..
        \ ')"'
endfunction
let s:b = {
      \ 'bibtool':                            'bibtool -q -s',
      \ 'black':                              'black -q -',
      \ 'vimscript_builtin':                   funcref('s:vimscript_builtin'),
      \ 'gofmt':                              'gofmt',
      \ 'leptosfmt':                          'leptosfmt --rustfmt --stdin --quiet',
      \ 'nginxfmt':                           'nginxfmt -',
      \ 'ocamlformat':                funcref('s:ocamlformat'),
      \ 'prettier':                   funcref('s:prettier'),
      \ 'prettier_svelte':            funcref('s:prettier_svelte'),
      \ 'prettier_prisma':            funcref('s:prettier_prisma'),
      \ 'prettier_no_explicit_range': funcref('s:prettier_no_explicit_range'),
      \ 'ruff':                       funcref('s:ruff'),
      \ 'rustfmt':                            'rustfmt --quiet',
      \ 'shfmt':                      funcref('s:shfmt'),
      \ 'styler':                     funcref('s:styler'),
      \ 'stylua':                     funcref('s:stylua'),
      \ 'terraform_fmt':                      'terraform fmt -',
      \ 'toml_sort':                          'toml-sort',
      \ }
let s:default_formatters = {
      \ 'bash':                s:b.shfmt,
      \ 'bib':                 s:b.bibtool,
      \ 'css':                 s:b.prettier,
      \ 'go':                  s:b.gofmt,
      \ 'graphql':             s:b.prettier,
      \ 'html':                s:b.prettier,
      \ 'javascript':          s:b.prettier,
      \ 'javascript.jsx':      s:b.prettier,
      \ 'javascriptreact':     s:b.prettier,
      \ 'jinja.html':          s:b.prettier,
      \ 'json':                s:b.prettier,
      \ 'jsonc':               s:b.prettier,
      \ 'lua':                 s:b.stylua,
      \ 'markdown':            s:b.prettier_no_explicit_range,
      \ 'markdown.mdx':        s:b.prettier_no_explicit_range,
      \ 'mdx':                 s:b.prettier_no_explicit_range,
      \ 'nginx':               s:b.nginxfmt,
      \ 'ocaml':               s:b.ocamlformat,
      \ 'prisma':              s:b.prettier_prisma,
      \ 'python':              s:b.black,
      \ 'r':                   s:b.styler,
      \ 'rust':                s:b.rustfmt,
      \ 'scss':                s:b.prettier,
      \ 'sh':                  s:b.shfmt,
      \ 'svelte':              s:b.prettier_svelte,
      \ 'terraform':           s:b.terraform_fmt,
      \ 'toml':                s:b.toml_sort,
      \ 'typescript':          s:b.prettier,
      \ 'typescript.tsx':      s:b.prettier,
      \ 'typescriptreact':     s:b.prettier,
      \ 'vim':                 s:b.vimscript_builtin,
      \ 'yaml':                s:b.prettier,
      \ 'yaml.docker-compose': s:b.prettier,
      \ }

function! s:configure_constants()
  " Only set this if you want confirmation on success
  if !exists('g:vim_filetype_formatter_verbose')
    let g:vim_filetype_formatter_verbose = v:false
  endif

  " Define built-in filetypes.
  if !exists('g:vim_filetype_formatter_builtins')
    let g:vim_filetype_formatter_builtins = s:b
  endif

  " Map weird filetypes to standard filetypes
  if !exists('g:vim_filetype_formatter_ft_maps')
    let g:vim_filetype_formatter_ft_maps = {}
  elseif type(g:vim_filetype_formatter_ft_maps) != v:t_dict
    throw 'User-configured g:vim_filetype_formatter_ft_no_defaults must be Dict'
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

function! s:cmd_filetypeformat() range
  let result = filetype_formatter#format_filetype(a:firstline, a:lastline)
endfunction

" Commands

if !s:cmd_exists(':FiletypeFormat')
  command -range=% FiletypeFormat silent!
        \ let b:filetype_formatter_winview = winsaveview()
        \ | <line1>,<line2>call s:cmd_filetypeformat()
        \ | silent call winrestview(b:filetype_formatter_winview)
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
