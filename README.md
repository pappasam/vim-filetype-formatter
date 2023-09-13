# Vim Filetype Formatter

A simple, cross-language Vim code formatter plugin supporting both range and full-file formatting. **It uses code formatters available in your $PATH; it does not install them.** The following languages are configured out of the box.

| Language                                                                      | Formatter                                                                                                           |
| ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| [**biblatex**](http://www.bibtex.org/)                                        | [bibtool](https://ctan.org/pkg/bibtool)                                                                             |
| [**css**](https://developer.mozilla.org/en-US/docs/Web/CSS)                   | [prettier](https://prettier.io/)                                                                                    |
| [**go**](https://golang.org/)                                                 | [gofmt](https://golang.org/cmd/gofmt/)                                                                              |
| [**graphql**](https://developer.mozilla.org/en-US/docs/Web/HTML)              | [prettier](https://prettier.io/)                                                                                    |
| [**html**](https://developer.mozilla.org/en-US/docs/Web/HTML)                 | [prettier](https://prettier.io/)                                                                                    |
| [**javascript/jsx**](https://developer.mozilla.org/en-US/docs/Web/JavaScript) | [prettier](https://prettier.io/)                                                                                    |
| [**json**](https://json.org/)                                                 | [prettier](https://prettier.io/)                                                                                    |
| [**jsonc**](https://komkom.github.io/)                                        | [prettier](https://prettier.io/)                                                                                    |
| [**lua**](https://www.lua.org/)                                               | [stylua](https://github.com/JohnnyMorganz/StyLua)                                                                   |
| [**markdown**](https://en.wikipedia.org/wiki/Markdown)                        | [prettier](https://prettier.io/)                                                                                    |
| [**mdx**](https://mdxjs.com/)                                                 | [prettier](https://prettier.io/)                                                                                    |
| [**nginx**](https://www.nginx.com/resources/wiki/start/topics/examples/full/) | [nginxfmt](https://github.com/slomkowski/nginx-config-formatter)                                                    |
| [**ocaml**](https://ocaml.org/)                                               | [ocamlformat](https://github.com/ocaml-ppx/ocamlformat)                                                             |
| [**prisma**](https://www.prisma.io/)                                          | [prettier](https://prettier.io/) + [prettier-plugin-prisma](https://github.com/umidbekk/prettier-plugin-prisma)     |
| [**python**](https://www.python.org/)                                         | [black](https://github.com/python/black)                                                                            |
| [**r**](https://www.r-project.org/)                                           | [styler](https://github.com/r-lib/styler)                                                                           |
| [**rust**](https://www.rust-lang.org/)                                        | [rustfmt](https://github.com/rust-lang/rustfmt)                                                                     |
| [**scss**](https://sass-lang.com/)                                            | [prettier](https://prettier.io/)                                                                                    |
| [**svelte**](https://svelte.dev/)                                             | [prettier](https://prettier.io/) + [prettier-plugin-svelte](https://github.com/UnwrittenFun/prettier-plugin-svelte) |
| [**terraform**](https://www.terraform.io/)                                    | [terraform fmt](https://www.terraform.io/docs/commands/fmt.html)                                                    |
| [**toml**](https://github.com/toml-lang/toml)                                 | [toml-sort](https://github.com/pappasam/toml-sort)                                                                  |
| [**typescript/tsx**](https://www.typescriptlang.org/)                         | [prettier](https://prettier.io/)                                                                                    |
| [**yaml**](https://yaml.org/)                                                 | [prettier](https://prettier.io/)                                                                                    |

Don't like the defaults? Writing your own is easy!

Each Vim filetype maps to one command-line command. This plugin supports any code formatter command as long as it:

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
nnoremap <silent> <leader>f :FiletypeFormat<cr>
vnoremap <silent> <leader>f :FiletypeFormat<cr>
```

If you're using [coc.nvim](https://github.com/neoclide/coc.nvim), and you want to prevent the language server from freaking out after running `:FiletypeFormat`, you can use the following mappings instead. They're just like the above mappings, but they explicitly turn off/on coc, which seems to get around any "language server"-side hiccups.

```vim
nnoremap <silent> <leader>f <Cmd>silent! CocDisable<cr><Cmd>FiletypeFormat<cr><Cmd>silent! CocEnable<cr>
vnoremap <silent> <leader>f <Cmd>silent! CocDisable<cr>:FiletypeFormat<cr><Cmd>silent! CocEnable<cr>
```

## Default configurations

Default configurations may be overridden by creating our own `g:vim_filetype_formatter_commands` dictionary. If you would like to map one filetype to another, see `g:vim_filetype_formatter_ft_maps`. See [here](./doc/filetype_formatter.txt) for specifics on how to do this.

## Non-standard code formatters

In the rare case where a required code formatter does not read from standard input and/or write to standard output, don't panic. With some effort, you can probably still create a working command by chaining the code formatter with standard Unix programs. See the following example, using [`nginxbeautifier`](https://github.com/vasilevich/nginxbeautifier):

```vim
\ 'nginx':
\   'dd status=none of=/tmp/nginx.conf >& /dev/null && '
\   . 'nginxbeautifier --space 4 /tmp/nginx.conf >& /dev/null && '
\   . 'cat /tmp/nginx.conf && '
\   . 'rm /tmp/nginx.conf',
```

1. `dd`: read `vim-filetype-formatter`'s standard output as standard input, writing to a temporary file named `/tmp/nginx.conf`
2. `nginxbeautifier`: read from the temporary file and modify that file in-place
3. `cat`: write the contents of the temporary file to stdout
4. `rm`: remove the temporary file to keep things tidy

It's not exactly pretty, but:

1. Reality isn't always pretty
2. We can use the command because it reads from standard input and writes to standard output

## Notes

This plugin prioritizes simplicity and ease of use on a POSIX-compliant system. Support for Windows and other non-Unix derivatives is out of scope.
