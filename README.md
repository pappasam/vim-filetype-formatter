# Vim-Filetype-Formatter

tl;dr: A simple, cross language Vim code formatter plugin.

Each Vim filetype may be associated with one command line code formatting program. Examples of qualifying code formatting programs include:

* Python: [yapf](https://github.com/google/yapf)
* Rust: [rustfmt](https://github.com/rust-lang/rustfmt)
* Terraform: [terraform fmt](https://www.terraform.io/docs/commands/fmt.html)

Virtually any code formatting program qualifies as long as it reads from standard input and writes to standard output.

## Installation

I recommend using [Vim-Plug](https://github.com/junegunn/vim-plug). Once you've installed Vim-Plug, place the following line in the Plugin section of your vimrc or your "init.vim":

```vim
" ~/.vimrc or ~/.config/nvim/init.vim
Plug 'pappasam/vim-filetype-formatter'
```

Now, execute the following Ex command:

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

We use a Vim Dictionary to map one filetype to one system command. See below for an example configuration for some of our users favorite formatters:

```vim
" ~/.vimrc or ~/.config/nvim/init.vim
let g:vim_filetype_formatter_commands = {
      \ 'python': 'black -q -',
      \ 'rust': 'rustfmt',
      \ 'terraform': 'terraform fmt -',
      \ 'json': 'python3 -c "import json, sys; print(json.dumps(json.load(sys.stdin), indent=2))"',
      \}
```

### Key mappings

This plugin provides no default key mappings. I recommend setting a key mapping like this:

```vim
" ~/.vimrc or ~/.config/nvim/init.vim
augroup mapping_vim_filetype_formatter
  autocmd FileType python,rust,terraform
        \ nnoremap <silent> <buffer> <leader>f :FiletypeFormat<cr>
augroup END
```

## Full Documentation

See [here](./doc/filetype_formatter.txt)

Or, from within Vim, type:

```vim
:help filetype_formatter
```

## Notes

This plugin is focused on simplicity and ease of use on a POSIX-compliant system. Support for Windows and other non-Unix derivatives is not currently in scope.

Additionally, I do not plan on supporting Vim ranges because of their required interface complexity. See [vim-black](https://github.com/pappasam/vim-black) if you need ranges with the Black code formatter. Other plugins, like [vim-autoformat](https://github.com/Chiel92/vim-autoformat), have included mechanisms for users to establish range mappings to system formatter commands; feel free to use that plugin if your needs demand ranges in certain cases.

## Written by

Samuel Roeca *samuel.roeca@gmail.com*
