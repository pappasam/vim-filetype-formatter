# Vim-Filetype-Formatter

A simple, cross language Vim code formatter plugin supporting both range and full-file formatting. By default, it provides the following filetype / formatter pairings:

- [**css**](https://developer.mozilla.org/en-US/docs/Web/CSS): [prettier](https://prettier.io/docs/en/index.html)
- [**go**](https://golang.org/): [gofmt](https://golang.org/cmd/gofmt/)
- [**html**](https://developer.mozilla.org/en-US/docs/Web/HTML): [prettier](https://prettier.io/docs/en/index.html)
- [**javascript**](https://developer.mozilla.org/en-US/docs/Web/JavaScript): [prettier](https://prettier.io/docs/en/index.html)
- [**json**](https://json.org/): [python.json](https://docs.python.org/3/library/json.html)
- [**markdown**](https://en.wikipedia.org/wiki/Markdown): [prettier](https://prettier.io/docs/en/index.html)
- [**python**](https://www.python.org/): [black](https://github.com/python/black)
- [**rust**](https://www.rust-lang.org/): [rustfmt](https://github.com/rust-lang/rustfmt)
- [**svelte**](https://svelte.dev/): [prettier](https://prettier.io/docs/en/index.html) + [prettier-plugin-svelte](https://github.com/UnwrittenFun/prettier-plugin-svelte)
- [**terraform**](https://www.terraform.io/): [terraform fmt](https://www.terraform.io/docs/commands/fmt.html)
- [**toml**](https://github.com/toml-lang/toml): [toml-sort](https://github.com/pappasam/toml-sort)
- [**typescript**](https://www.typescriptlang.org/): [prettier](https://prettier.io/docs/en/index.html)
- [**yaml**](https://yaml.org/): [prettier](https://prettier.io/docs/en/index.html)

Don't like the defaults? Writing custom commands is easy!

Each Vim filetype maps to one command-line code-formatting command. This plugin supports any language code formatter as long as it:

1. Reads from standard input.
2. Writes to standard output.
3. Is in your PATH.

Requires a recent version of Neovim or Vim 8.

## Differentiating Features

- Respects configuration files (pyproject.toml, .rustfmt.toml, .prettierrc.toml, etc)
- Accepts visually-selected ranges for any formatter
- Preserves Vim cursor location after the formatter has run
- Clear logging so you can see why a formatter is or isn't working (:LogFiletypeFormat)
- Chain formatters together with Unix pipes
- Configurable, with sane defaults
- Simple, extendable codebase
- Modular: does not pollute your Vim environment with remappings / poor Vim plugin practices

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

## Full Documentation

From within Vim, type:

```vim
:help filetype_formatter
```

The following sections give some basic configuration examples.

## Configuration Basics

### g:vim_filetype_formatter_commands

- Type: `Dictionary[String, Union[String, F]]`
- F: `Union[Function[] -> String, Function[int, int] -> String]`
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

Default configurations may be overridden by creating our own `g:vim_filetype_formatter_commands` dictionary. To see the latest provided options, please see [here](./autoload/filetype_formatter/ft.vim).

## Notes

This plugin prioritizes simplicity and ease of use on a POSIX-compliant system. Support for Windows and other non-Unix derivatives is out of scope.

## Written by

Samuel Roeca _samuel.roeca@gmail.com_
