# Vim-Filetype-Formatter

A simple, cross language Vim code formatter plugin supporting both range and full-file formatting. By default, it provides the following filetype formatters:

- [**biblatex**](http://www.bibtex.org/): [bibtool](https://ctan.org/pkg/bibtool)
- [**css**](https://developer.mozilla.org/en-US/docs/Web/CSS): [prettier](https://prettier.io/)
- [**go**](https://golang.org/): [gofmt](https://golang.org/cmd/gofmt/)
- [**html**](https://developer.mozilla.org/en-US/docs/Web/HTML): [prettier](https://prettier.io/)
- [**javascript**](https://developer.mozilla.org/en-US/docs/Web/JavaScript): [prettier](https://prettier.io/)
- [**json**](https://json.org/): [prettier](https://prettier.io/)
- [**jsonc**](https://komkom.github.io/): [prettier](https://prettier.io/)
- [**markdown**](https://en.wikipedia.org/wiki/Markdown): [prettier](https://prettier.io/)
- [**ocaml**](https://ocaml.org/): [ocamlformat](https://github.com/ocaml-ppx/ocamlformat)
- [**python**](https://www.python.org/): [black](https://github.com/python/black)
- [**rust**](https://www.rust-lang.org/): [rustfmt](https://github.com/rust-lang/rustfmt)
- [**svelte**](https://svelte.dev/): [prettier](https://prettier.io/) + [prettier-plugin-svelte](https://github.com/UnwrittenFun/prettier-plugin-svelte)
- [**terraform**](https://www.terraform.io/): [terraform fmt](https://www.terraform.io/docs/commands/fmt.html)
- [**toml**](https://github.com/toml-lang/toml): [toml-sort](https://github.com/pappasam/toml-sort)
- [**typescript**](https://www.typescriptlang.org/): [prettier](https://prettier.io/)
- [**yaml**](https://yaml.org/): [prettier](https://prettier.io/)

Don't like the defaults? Writing custom commands is easy!

Each Vim filetype maps to one command-line code-formatting command. This plugin supports any language code formatter as long as it:

1. Reads from standard input.
2. Writes to standard output.
3. Is in your PATH. Vim-filetype-formatter uses code formatters; it does not install them.

Requires:

- A recent version of Neovim or Vim 8.
- Bash (/bin/bash)

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

## Key mappings

This plugin provides no default key mappings. I recommend setting a key mapping for normal mode and visual mode like this:

```vim
" ~/.vimrc
nnoremap <leader>f :FiletypeFormat<cr>
vnoremap <leader>f :FiletypeFormat<cr>
```

## Default configurations

Default configurations may be overridden by creating our own `g:vim_filetype_formatter_commands` dictionary. If you would like to map one filetype to another, see `g:vim_filetype_formatter_ft_maps`. See [here](./doc/filetype_formatter.txt) for specifics on how to do this.

## Notes

This plugin prioritizes simplicity and ease of use on a POSIX-compliant system. Support for Windows and other non-Unix derivatives is out of scope.

## Written by

Samuel Roeca _samuel.roeca@gmail.com_
