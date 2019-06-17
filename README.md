# Vim-Filetype-Formatter

tl;dr: A simple, cross language Vim code formatter plugin supporting full file formatting, range formatting, and sane behavior. Requires Vim 8 or a recent version of Neovim.

Each Vim filetype may be associated with one command-line code-formatting command. This plugin supports any language, as long as it has a compliant code formatter program(s). See the end of this document for supported formatters / filetypes (there's a lot!). Virtually any code-formatting program qualifies as long as it reads from standard input and writes to standard output. Default configurations are provided for:

- css: [prettier](https://prettier.io/docs/en/index.html)
- go: [gofmt](https://golang.org/cmd/gofmt/)
- html: [prettier](https://prettier.io/docs/en/index.html)
- javascript: [prettier](https://prettier.io/docs/en/index.html)
- json: [python.json](https://docs.python.org/3/library/json.html)
- markdown: [prettier](https://prettier.io/docs/en/index.html)
- python: [black](https://github.com/python/black)
- rust: [rustfmt](https://github.com/rust-lang/rustfmt)
- terraform: [terraform fmt](https://www.terraform.io/docs/commands/fmt.html)
- yaml: [prettier](https://prettier.io/docs/en/index.html)

Don't like the defaults? It's super easy to write your own! We provide many pre-defined formatter variables in `g:filetype_formatter#ft#formatters` to make your life as easy as possible! And writing your own command is trivial; read on to discover the simplest code-formatting experience in Vim!

## Differentiating Features

- Respects your formatter's configuration files (pyproject.toml, .rustfmt.toml, .prettierrc.toml, etc)
- Modular: does not pollute your Vim environment with remappings / poor Vim plugin practices
- Keeps your Vim cursor in a sane location after the formatter has run
- Gives you configurable access to clear logging so you can see how and why any formatter is/isn't working
- Ability to chain formatters together with Unix pipes
- Works on visually-selected ranges for formatters that accept ranges, and even for code formatters **without** explicit range support!
- Sane, yet override-able, defaults
- Simple, extendable codebase

## Installation

Use [Vim-Plug](https://github.com/junegunn/vim-plug). Once you've installed Vim-Plug, place the following line in the Plugin section of your vimrc:

```vim
" ~/.vimrc
Plug 'pappasam/vim-filetype-formatter'
```

Then run the Ex command:

```vim
:PlugInstall
```

## Configuration Basics

### g:vim_filetype_formatter_commands

- Type: `Dictionary[String, Union[String, F]]`
- F: `Function[int, int] -> String`
- Default: `g:filetype_formatter#ft#defaults`

Configuration consists of two components:

1. A Vim filetype
2. A system command that accepts the following [standard stream](https://en.wikipedia.org/wiki/Standard_streams): reads from standard input, writes to standard output. The command is either a **string** or a Vim **function**. A function either accepts 0 arguments or 2 arguments (the start and the end line)

```vim
" ~/.vimrc
let g:vim_filetype_formatter_commands = {
      \ 'javascript': {-> printf('npx prettier --stdin --stdin-filepath="%s"', expand('%:p'))},
      \ 'json': 'python3 -c "import json, sys; print(json.dumps(json.load(sys.stdin), indent=2), end=\"\")"',
      \ 'python': {start, end -> printf('yapf --lines=%d-%d', start, end)},
      \ 'terraform': 'terraform fmt -',
      \ }
```

### Key mappings

This plugin provides no default key mappings. I recommend setting a key mapping for normal mode and visual mode like this:

```vim
" ~/.vimrc
nnoremap <leader>f :FiletypeFormat<cr>
vnoremap <leader>f :FiletypeFormat<cr>
```

### Default configurations

Many default configurations are provided out of the box and may be overridden by creating our own `g:vim_filetype_formatter_commands` dictionary. To see the latest provided options, please see [here](./autoload/filetype_formatter/ft.vim).

## Full Documentation

See [here](./doc/filetype_formatter.txt)

From within Vim, type:

```vim
:help filetype_formatter
```

## Notes

This plugin is focused on simplicity and ease of use on a POSIX-compliant system. Support for Windows and other non-Unix derivatives is not currently in scope.

## Written by

Samuel Roeca _samuel.roeca@gmail.com_
