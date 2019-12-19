""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OriginalAuthor: Samuel Roeca
" Maintainer:     Samuel Roeca samuel.roeca@gmail.com
" Description:    vim-filetype-formatter: your favorite code formatters in Vim
"                 Contains default values for popular code formatters, by
"                 filetype
" License:        MIT License
" Website:        https://github.com/pappasam/vim-filetype-formatter
" License:        MIT
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Dry Helpers: helper functions to reduce repetition
function! s:get_prettier()
  return {-> printf(
        \ 'npx --no-install prettier --stdin --stdin-filepath="%s"',
        \ expand('%:p')
        \ )}
endfunction

" Default Formatters: all pre-configured formatters live in the
" filetype_formatter#ft#formatters variable. Formatters must either be:
"   1) A String
"   2) A function(start: Integer, end: Integer) -> String
"   3) A function() -> String
let g:filetype_formatter#ft#formatters = {}
let g:filetype_formatter#ft#formatters['bib']= {
      \ 'bibclean': 'bibclean --no-warnings',
      \ 'bibtool': 'bibtool -q -s',
      \ }
let g:filetype_formatter#ft#formatters['css']= {
      \ 'prettier': s:get_prettier(),
      \ }
let g:filetype_formatter#ft#formatters['go'] = {
      \ 'gofmt': 'gofmt',
      \ }
let g:filetype_formatter#ft#formatters['html']= {
      \ 'prettier': s:get_prettier(),
      \ }
let g:filetype_formatter#ft#formatters['javascript']= {
      \ 'prettier': s:get_prettier(),
      \ }
let g:filetype_formatter#ft#formatters['json'] = {
      \ 'python.json': 'python3 -c "import json, sys;'
      \                . 'print(json.dumps(json.load(sys.stdin),'
      \                . 'indent=2), end=\"\")"',
      \ }
let g:filetype_formatter#ft#formatters['markdown'] = {
      \ 'prettier': s:get_prettier(),
      \ }
let g:filetype_formatter#ft#formatters['ocaml'] = {
      \ 'ocamlformat': {-> 'ocamlformat --enable-outside-detected-project '
      \                 . '--name ' . expand('%') . ' -'},
      \ }
let g:filetype_formatter#ft#formatters['python'] = {
      \ 'black': 'black -q -',
      \ 'yapf': {start, end -> printf('yapf --lines=%d-%d', start, end)},
      \ }
let g:filetype_formatter#ft#formatters['rust'] = {
      \ 'rustfmt': 'rustfmt --quiet',
      \ }
let g:filetype_formatter#ft#formatters['svelte']= {
      \ 'prettier': s:get_prettier(),
      \ }
let g:filetype_formatter#ft#formatters['terraform'] = {
      \ 'terraform fmt': 'terraform fmt -',
      \ }
let g:filetype_formatter#ft#formatters['toml'] = {
      \ 'toml-sort': 'toml-sort',
      \ }
let g:filetype_formatter#ft#formatters['typescript'] = {
      \ 'prettier': s:get_prettier(),
      \ }
let g:filetype_formatter#ft#formatters['yaml'] = {
      \ 'prettier': s:get_prettier(),
      \ }

" Defaults: language defaults live in the below dictionary
let g:filetype_formatter#ft#defaults = {
      \ 'bib': g:filetype_formatter#ft#formatters['bib']['bibtool'],
      \ 'css': g:filetype_formatter#ft#formatters['css']['prettier'],
      \ 'go': g:filetype_formatter#ft#formatters['go']['gofmt'],
      \ 'html': g:filetype_formatter#ft#formatters['html']['prettier'],
      \ 'javascript': g:filetype_formatter#ft#formatters['javascript']['prettier'],
      \ 'javascript.jsx': g:filetype_formatter#ft#formatters['javascript']['prettier'],
      \ 'json': g:filetype_formatter#ft#formatters['json']['python.json'],
      \ 'markdown': g:filetype_formatter#ft#formatters['markdown']['prettier'],
      \ 'ocaml': g:filetype_formatter#ft#formatters['ocaml']['ocamlformat'],
      \ 'python': g:filetype_formatter#ft#formatters['python']['black'],
      \ 'rust': g:filetype_formatter#ft#formatters['rust']['rustfmt'],
      \ 'terraform': g:filetype_formatter#ft#formatters['terraform']['terraform fmt'],
      \ 'toml': g:filetype_formatter#ft#formatters['toml']['toml-sort'],
      \ 'typescript': g:filetype_formatter#ft#formatters['typescript']['prettier'],
      \ 'typescript.tsx': g:filetype_formatter#ft#formatters['typescript']['prettier'],
      \ 'svelte': g:filetype_formatter#ft#formatters['svelte']['prettier'],
      \ 'yaml': g:filetype_formatter#ft#formatters['yaml']['prettier'],
      \ 'yaml.docker-compose': g:filetype_formatter#ft#formatters['yaml']['prettier'],
      \ }
