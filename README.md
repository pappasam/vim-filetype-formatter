# Vim-Filetype-Formatter

tl;dr: A simple, cross language Vim code formatter plugin supporting full file formatting, range formatting, and sane behavior.

Each Vim filetype may be associated with one command-line code-formatting command. This plugin supports any language, as long as it has a compliant code formatter program. See the end of this document for supported formatters / filetypes (there's a lot!). Virtually any code-formatting program qualifies as long as it reads from standard input and writes to standard output. An example configuration, in your vimrc, might look like this:

```vim
" ~/.vimrc
let g:vim_filetype_formatter_commands = {
      \ 'go': 'gofmt',
      \ 'html': 'npx prettier --parser=html --stdin',
      \ 'json': 'python3 -c "import json, sys; print(json.dumps(json.load(sys.stdin), indent=2), end=\"\")"',
      \ 'python': 'black -q -',
      \ 'rust': 'rustfmt',
      \ 'terraform': 'terraform fmt -',
      \ }

nnoremap <leader>f :FiletypeFormat<cr>
vnoremap <leader>f :FiletypeFormat<cr>
```

## Differentiating Features

* Respects your formatter's configuration files (pyproject.toml, .rustfmt.toml, .prettierrc.toml, etc)
* Modular: does not pollute your Vim environment with remappings / poor Vim plugin practices
* Keeps your Vim cursor in a sane location after the formatter has run
* Gives you configurable access to clear logging so you can see how and why any formatter is/isn't working
* Ability to chain formatters together with Unix pipes
* Works on visually-selected ranges, perfectly for formatters that accept ranges, and imperfectly even for code formatters **without** range support!
* Simple, extendable codebase

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

* Type: Dictionary[String, Union[String, F]]
* F: Function[int, int] -> String
* Default: {}

Configuration consists of two components:

1. A Vim filetype
2. A system command that accepts the following [standard stream](https://en.wikipedia.org/wiki/Standard_streams): reads from standard input, writes to standard output. The command is either a **string** or a Vim **function** that accepts two arguments: the start line and the end line.

### Key mappings

This plugin provides no default key mappings. I recommend setting a key mapping for normal mode and visual mode like this:

```vim
" ~/.vimrc
nnoremap <leader>f :FiletypeFormat<cr>
vnoremap <leader>f :FiletypeFormat<cr>
```

### Recommended formatter configurations

We do not intend to pollute the codebase with example configurations for formatters. Instead, we provide example configurations below to help the user get started. Please see below for recommended configurations, by filetype, for some popular code formatters.

#### Go

**gofmt**

```vim
\ 'go': 'gofmt',
```

#### HTML

**prettier**

```vim
\ 'html': 'npx prettier --parser=html --stdin',
```

#### JSON

**Python 3 json module**

```vim
\ 'json': 'python3 -c "import json, sys; print(json.dumps(json.load(sys.stdin), indent=2), end=\"\")"',
```
#### Python

**yapf**

```vim
\ 'python': {start, end -> printf('yapf --lines=%d-%d', start, end)},
```

**black**

```vim
\ 'python': 'black -q -',
```


#### Rust

**Rustfmt**

```vim
\ 'rust': 'rustfmt',
```

#### Terraform

**TerraformFmt**

```vim
\ 'terraform': 'terraform fmt -',
```

## Full Documentation

See [here](./doc/filetype_formatter.txt)

From within Vim, type:

```vim
:help filetype_formatter
```

## Notes

This plugin is focused on simplicity and ease of use on a POSIX-compliant system. Support for Windows and other non-Unix derivatives is not currently in scope.

## Written by

Samuel Roeca *samuel.roeca@gmail.com*
