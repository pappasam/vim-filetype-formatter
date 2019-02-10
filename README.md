# Vim-Filetype-Formatter

tl;dr: A simple, cross language Vim code formatter plugin.

Each Vim filetype may be associated with one command-line code-formatting program. Examples of qualifying code-formatting programs include:

* Go: [gofmt](https://golang.org/cmd/gofmt/)
* Python: [yapf](https://github.com/google/yapf)
* Rust: [rustfmt](https://github.com/rust-lang/rustfmt)
* Terraform: [terraform fmt](https://www.terraform.io/docs/commands/fmt.html)
* Etc...

Virtually any code-formatting program qualifies as long as it reads from standard input and writes to standard output.

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

* Type: Dictionary[String, String]
* Default: {}

Configuration consists of two components:

1. A Vim filetype
2. A system command that accepts the following [standard stream](https://en.wikipedia.org/wiki/Standard_streams): reads from standard input, writes to standard output

We use a Vim Dictionary to map one filetype to one system command. See below for an example configuration for some of our users' favorite formatters:

```vim
" ~/.vimrc
let g:vim_filetype_formatter_commands = {
      \ 'go': 'gofmt',
      \ 'json': 'python3 -c "import json, sys; print(json.dumps(json.load(sys.stdin), indent=2))"',
      \ 'python': 'yapf',
      \ 'rust': 'rustfmt',
      \ 'terraform': 'terraform fmt -',
      \}
```

### Key mappings

This plugin provides no default key mappings. I recommend setting a key mapping like this:

```vim
" ~/.vimrc
nnoremap <leader>f :FiletypeFormat<cr>
```

## Full Documentation

See [here](./doc/filetype_formatter.txt)

From within Vim, type:

```vim
:help filetype_formatter
```

## Notes

This plugin is focused on simplicity and ease of use on a POSIX-compliant system. Support for Windows and other non-Unix derivatives is not currently in scope. Additionally, I do not plan on supporting Vim ranges because of their required interface complexity.

## Written by

Samuel Roeca *samuel.roeca@gmail.com*
