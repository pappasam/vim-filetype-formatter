""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-filetype-formatter: your favorite code formatters in Vim
" License:        MIT License
" Website:        https://github.com/pappasam/vim-filetype-formatter
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set plugin defaults
let s:prettier = {-> printf('npx --no-install prettier --stdin-filepath="%s"', expand('%:p'))}
let s:default_formatters = {
      \ 'bib': 'bibtool -q -s',
      \ 'css': s:prettier,
      \ 'go': 'gofmt',
      \ 'html': s:prettier,
      \ 'javascript': s:prettier,
      \ 'json': s:prettier,
      \ 'markdown': s:prettier,
      \ 'ocaml': {-> 'ocamlformat --enable-outside-detected-project ' . '--name ' . expand('%') . ' -'},
      \ 'python': 'black -q -',
      \ 'rust': 'rustfmt --quiet',
      \ 'terraform': 'terraform fmt -',
      \ 'toml': 'toml-sort',
      \ 'typescript': s:prettier,
      \ 'svelte': s:prettier,
      \ 'yaml': s:prettier,
      \ }

" Only set this if you want confirmation on success
if !exists('g:vim_filetype_formatter_verbose')
  let g:vim_filetype_formatter_verbose = 0
endif

" Map weird filetypes to standard filetypes
if !exists('g:vim_filetype_formatter_ft_maps')
  let g:vim_filetype_formatter_ft_maps = {
    \ 'javascript.jsx': 'javascript',
    \ 'typescript.tsx': 'typescript',
    \ 'yaml.docker-compose': 'yaml',
    \ }
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

" Commands
command! -range=% FiletypeFormat silent!
      \ let b:filetype_formatter_winview = winsaveview()
      \ | <line1>,<line2>call filetype_formatter#format_filetype()
      \ | silent call winrestview(b:filetype_formatter_winview)

command! LogFiletypeFormat call filetype_formatter#echo_log()
