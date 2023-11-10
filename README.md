# Vim Filetype Formatter

A simple, cross-language Vim code formatter plugin supporting both range and full-file formatting. **It uses code formatters available in your $PATH; it does not install them.**

See our [pre-configured languages and formatters](#batteries-included). Don't like the defaults? Writing your own is easy! Each Vim filetype maps to one command-line command. This plugin supports any code formatter command as long as it:

1. Reads from standard input.
2. Writes to standard output.
3. Is in your `$PATH`.

Requires Bash and a recent version of Vim or Neovim.

## Differentiating Features

- Respects configuration files (`pyproject.toml`, `.rustfmt.toml`, `.prettierrc.toml`, etc.)
- Accepts visually-selected ranges for any formatter
- Preserves Vim cursor location after the formatter has run
- Clear logging, so you can see why a formatter is or isn't working (`:LogFiletypeFormat`)
- Easy debugging of user configuration (`:DebugFiletypeFormat`)
- Chain formatters together with Unix pipes
- Configurable, with sane defaults
- Simple, extendable codebase
- Modular: does not pollute your Vim environment with custom key mappings / poor Vim plugin practices

The following screencast demonstrates `:FiletypeFormat`, `:LogFiletypeFormat`, and `:DebugFiletypeFormat`.

![Screencast](./img/vim-filetype-formatter-walkthrough.gif)

Although [black](https://github.com/psf/black) works out of the box for Python, the above example overrides the default and combines black with [isort](https://github.com/PyCQA/isort) and [docformatter](https://github.com/myint/docformatter) using Unix pipes. This specific example can be achieved with the following configuration in your `vimrc` or `init.vim`:

```vim
let g:vim_filetype_formatter_commands = {
      \ 'python': 'black -q - | isort -q - | docformatter -',
      \ }
```

For further customization (e.g., where you need anything dynamic), you can pass either a [`Funcref`](https://neovim.io/doc/user/eval.html#Funcref) or a [`lambda expression`](https://neovim.io/doc/user/eval.html#expr-lambda). For example, you might want to pass the current filename as an argument to your command line program. Here is an example for Python using a lambda expression:

```vim
let g:vim_filetype_formatter_commands = {
      \ 'python': {-> printf('black -q --stdin-filename="%1$s" - | isort -q --filename="%1$s" - | docformatter -', expand('%:p'))},
      \ }
```

Here's another Python example involving [ruff](https://github.com/astral-sh/ruff).

```vim
function s:formatter_python()
  return printf(
        \ 'ruff check --unsafe-fixes -q --fix-only --stdin-filename="%1$s" - | ' ..
        \ 'ruff format -q --stdin-filename="%1$s" -',
        \ expand('%:p'))
endfunction
let g:vim_filetype_formatter_commands = {'python': function('s:formatter_python')}
```

Finally, here's an example of how we can support prettier's built-in range functionality:

```vim
function! s:prettier(startline, endline)
  return printf(
        \ 'npx --no-update-notifier --silent --no-install prettier --range-start=%i --range-end=%i --stdin-filepath="%s"',
        \ line2byte(a:startline) - 1,
        \ line2byte(a:endline + 1) - 1,
        \ expand('%:p')
        \ )
endfunction
let g:vim_filetype_formatter_commands = {'javascript': function('s:prettier')}
```

## Installation

If using [vim-plug](https://github.com/junegunn/vim-plug), place the following line in the Plugin section of your `init.vim` / `vimrc`:

```vim
Plug 'pappasam/vim-filetype-formatter'
```

Then run the Ex command:

```vim
:PlugInstall
```

I personally use [vim-packager](https://github.com/kristijanhusak/vim-packager), so if you'd like to go down the "package" rabbit hole, I suggest giving that a try.

## Full Documentation

From within Vim, type:

```vim
:help filetype_formatter
```

## Key mappings

This plugin provides no default key mappings. I recommend setting a key mapping for normal mode and visual mode like this:

```vim
nnoremap <silent> <leader>f <Cmd>FiletypeFormat<CR>
xnoremap <silent> <leader>f :FiletypeFormat<CR>
```

## Default configurations

Default configurations may be overridden by creating our own `g:vim_filetype_formatter_commands` dictionary. If you would like to map one filetype to another, see `g:vim_filetype_formatter_ft_maps`. See [here](./doc/filetype_formatter.txt) for specifics on how to do this.

If you would like to use a formatter listed above in "Other Formatters", you'll first need to `packadd vim-filetype-formatter` and then add it to `g:vim_filetype_formatter` commands. Here is an example of how to override Python's formatter with the built-in configuration for `ruff`:

```vim
packadd vim-filetype-formatter
let g:vim_filetype_formatter_commands.python = g:vim_filetype_formatter_builtins.ruff
```

## Non-standard code formatters

In the rare case where a required code formatter does not read from standard input and/or write to standard output, don't panic. With some effort, you can probably still create a working command by chaining the code formatter with standard Unix programs. See the following example, using [`nginxbeautifier`](https://github.com/vasilevich/nginxbeautifier):

```vim
\ 'nginx':
\   'dd status=none of=/tmp/nginx.conf >& /dev/null && '
\   .. 'nginxbeautifier --space 4 /tmp/nginx.conf >& /dev/null && '
\   .. 'cat /tmp/nginx.conf && '
\   .. 'rm /tmp/nginx.conf',
```

1. `dd`: read `vim-filetype-formatter`'s standard output as standard input, writing to a temporary file named `/tmp/nginx.conf`
2. `nginxbeautifier`: read from the temporary file and modify that file in-place
3. `cat`: write the contents of the temporary file to stdout
4. `rm`: remove the temporary file to keep things tidy

It's not exactly pretty, but:

1. Reality isn't always pretty
2. We can use the command because it reads from standard input and writes to standard output

## Batteries Included

| Language         | Default Formatter | Other Formatters |
| ---------------- | ----------------- | ---------------- |
| [bash/sh]        | [shfmt]           |                  |
| [biblatex]       | [bibtool]         |                  |
| [css]            | [prettier]        |                  |
| [go]             | [gofmt]           |                  |
| [graphql]        | [prettier]        |                  |
| [html]           | [prettier]        |                  |
| [javascript/jsx] | [prettier]        |                  |
| [json]           | [prettier]        |                  |
| [jsonc]          | [prettier]        |                  |
| [lua]            | [stylua]          |                  |
| [markdown]       | [prettier]        |                  |
| [mdx]            | [prettier]        |                  |
| [nginx]          | [nginxfmt]        |                  |
| [ocaml]          | [ocamlformat]     |                  |
| [prisma]         | [prettier_prisma] |                  |
| [python]         | [black]           | [ruff]           |
| [r]              | [styler]          |                  |
| [rust]           | [rustfmt]         |                  |
| [scss]           | [prettier]        |                  |
| [svelte]         | [prettier_svelte] |                  |
| [terraform]      | [terraform_fmt]   |                  |
| [toml]           | [toml_sort]       |                  |
| [typescript/tsx] | [prettier]        |                  |
| [yaml]           | [prettier]        |                  |

<!-- formatters -->

[bibtool]: https://ctan.org/pkg/bibtool
[black]: https://github.com/python/black
[gofmt]: https://golang.org/cmd/gofmt/
[nginxfmt]: https://github.com/slomkowski/nginx-config-formatter
[ocamlformat]: https://github.com/ocaml-ppx/ocamlformat
[prettier_prisma]: https://github.com/umidbekk/prettier-plugin-prisma
[prettier_svelte]: https://github.com/UnwrittenFun/prettier-plugin-svelte
[prettier]: https://prettier.io/
[ruff]: https://github.com/astral-sh/ruff
[rustfmt]: https://github.com/rust-lang/rustfmt
[shfmt]: https://github.com/mvdan/sh
[styler]: https://github.com/r-lib/styler
[stylua]: https://github.com/JohnnyMorganz/StyLua
[terraform_fmt]: https://www.terraform.io/docs/commands/fmt.html
[toml_sort]: https://github.com/pappasam/toml-sort

<!-- languages -->

[bash/sh]: https://en.wikipedia.org/wiki/Bash_(Unix_shell)
[biblatex]: http://www.bibtex.org/
[css]: https://developer.mozilla.org/en-US/docs/Web/CSS
[go]: https://golang.org/
[graphql]: https://developer.mozilla.org/en-US/docs/Web/HTML
[html]: https://developer.mozilla.org/en-US/docs/Web/HTML
[javascript/jsx]: https://developer.mozilla.org/en-US/docs/Web/JavaScript
[json]: https://json.org/
[jsonc]: https://komkom.github.io/
[lua]: https://www.lua.org/
[markdown]: https://en.wikipedia.org/wiki/Markdown
[mdx]: https://mdxjs.com/
[nginx]: https://www.nginx.com/resources/wiki/start/topics/examples/full/
[ocaml]: https://ocaml.org/
[prisma]: https://www.prisma.io/
[python]: https://www.python.org/
[r]: https://www.r-project.org/
[rust]: https://www.rust-lang.org/
[scss]: https://sass-lang.com/
[svelte]: https://svelte.dev/
[terraform]: https://www.terraform.io/
[toml]: https://github.com/toml-lang/toml
[typescript/tsx]: https://www.typescriptlang.org/
[yaml]: https://yaml.org/

## FAQ

### Is this compatible with coc.nvim

If you're using [coc.nvim](https://github.com/neoclide/coc.nvim), and you want to prevent the language server from freaking out after running `:FiletypeFormat`, you can use the following mappings instead. They're just like the above mappings, but they explicitly turn off/on coc, which seems to get around any "language server"-side hiccups.

```vim
nnoremap <silent> <leader>f <Cmd>silent! CocDisable<CR><Cmd>FiletypeFormat<cr><Cmd>silent! CocEnable<CR>
xnoremap <silent> <leader>f <Cmd>silent! CocDisable<CR>:FiletypeFormat<cr><Cmd>silent! CocEnable<CR>
```
