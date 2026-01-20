# Vim Filetype Formatter

A simple, cross-language Vim code formatter plugin supporting both range and full-file formatting.

**It uses code formatters; it does not install them.**

See our [pre-configured languages and formatters](#batteries-included). Don't like the defaults? Writing your own is easy! Each Vim filetype maps to one command. This plugin supports compatible Vim commands, or any command line code formatter as long as it:

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

## Screencast

The following screencast demonstrates `:FiletypeFormat`, `:LogFiletypeFormat`, and `:DebugFiletypeFormat`.

![Screencast](./img/vim-filetype-formatter-walkthrough.gif)

## Configuration Overview

If you want to combine black with [isort](https://github.com/PyCQA/isort) and [docformatter](https://github.com/myint/docformatter) using Unix pipes. This specific example can be achieved with the following configuration in your `vimrc` or `init.vim`:

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

Here's an example of how we can support prettier's built-in range functionality:

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

Finally, custom Vim commands may be used instead of shell commands by ensuring that your final string is prefixed with a `:`. For an example implementation, see here:

```vim
" Use vim's built-in commands.
" 1. = (the vimscript_builtin)
" 2. Replace all instances of multiple blank lines, shortening to a single
function! s:vimscript_builtin(startline, endline)
  return printf(
        \ ':silent! execute "normal! %igg=%igg" | silent! %i,%iglobal/^\_$\n\_^$/de',
        \ a:startline, a:endline,
        \ a:startline, a:endline
        \ )
endfunction
let g:vim_filetype_formatter_commands = {'vim': function('s:vimscript_builtin')}
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

If you would like to use a formatter listed above in "Other Formatters", you'll first need to `packadd vim-filetype-formatter` and then add it to `g:vim_filetype_formatter` commands. Here is an example of how to override Python's formatter with the built-in configuration for `black`:

```vim
packadd vim-filetype-formatter
let g:vim_filetype_formatter_commands.python = g:vim_filetype_formatter_builtins.black
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

| Language | Default Formatter | Other Formatters |
| -- | -- | -- |
| [bash/sh] | [shfmt] |  |
| [biblatex] | [bibtool] |  |
| [css] | [prettier] | [biome] |
| [dockerfile] | [vim.lsp.buf.format] |  |
| [dosini] | [built-in] |  |
| [gitconfig] | [built-in] |  |
| [go] | [gofmt] |  |
| [graphql] | [prettier] | [biome] |
| [html] | [prettier] | [biome] |
| [htmldjango] | [prettier_jinja] |  |
| [javascript/jsx] | [prettier] | [biome] |
| [jinja.html] | [prettier_jinja] |  |
| [json] | [prettier] | [biome] |
| [jsonc] | [prettier] | [biome] |
| [lua] | [stylua] |  |
| [make] | [built-in] |  |
| [markdown] | [mdformat] | [prettier] |
| [mdx] | [prettier] |  |
| [nginx] | [nginxfmt] |  |
| [ocaml] | [ocamlformat] |  |
| [prisma] | [prettier_prisma] |  |
| [python] | [ruff] | [black] |
| [r] | [styler] |  |
| [rust] | [rustfmt] | [leptosfmt] |
| [scss] | [prettier] |  |
| [svelte] | [prettier_svelte] |  |
| [terraform] | [terraform_fmt] |  |
| [toml] | [taplo] |  |
| [typescript/tsx] | [prettier] | [biome] |
| [vimscript] | [built-in] |  |
| [xml] | [xq] |  |
| [yaml] | [prettier] |  |
| [zig] | [zig fmt] |  |
| [zsh] | [built-in] |  |

## FAQ

### How can I use an executable from my project's node_modules/ folder?

For example, if you have a different version of prettier installed in your project than you installed globally, you'll probably want vim-filetype-formatter to use your project's version of prettier. To achieve this:

1. Place the following line in `init.vim` / `.vimrc`:
   ```vim
   let $PATH = $PWD .. '/node_modules/.bin:' .. $PATH
   ```
2. Open Neovim at the root of your project.
3. You should now be referencing executable files within your project's `node_modules/` folder.

### How can I have per-project settings?

If using a recent version of Neovim, see `:help 'exrc'`.

```vim
" $XDG_CONFIG_HOME/init.vim
set exrc
" $PROJECT_PATH/.nvimrc
packadd vim-filetype-formatter
let g:vim_filetype_formatter_commands['python'] = g:vim_filetype_formatter_builtins['black']
let g:vim_filetype_formatter_commands['rust'] = g:vim_filetype_formatter_builtins['leptosfmt']
```

### The biome formatter isn't working

See: <https://github.com/biomejs/biome/issues/6783>

This assumes you're using biome. Here's an example where we've enabled biome for JSON and JSONC.

```vim
packadd vim-filetype-formatter
let g:vim_filetype_formatter_commands.json = g:vim_filetype_formatter_builtins.biome
let g:vim_filetype_formatter_commands.jsonc = g:vim_filetype_formatter_builtins.biome
```

Solution: create this `biome.json` at your home directory. This will serve as your default biome configuration file.

```json
{
  "$schema": "https://biomejs.dev/schemas/2.0.5/schema.json",
  "files": {
    "includes": ["**"]
  },
  "formatter": {
    "enabled": true,
    "includes": ["**"]
  }
}
```

You can put other biome configurations into this file as well so that, by default, your editor will behave consistently. For example, if you prefer spaces over tabs:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.0.5/schema.json",
  "files": {
    "includes": ["**"]
  },
  "formatter": {
    "enabled": true,
    "includes": ["**"],
    "indentStyle": "space"
  }
}
```

Don't worry: biome will defer to a project-specific file, so this is only important when you're not working on a project that has explicitly configured biome. See: <https://biomejs.dev/guides/configure-biome/#configuration-file-resolution>

[bash/sh]: https://en.wikipedia.org/wiki/Bash_(Unix_shell)
[biblatex]: http://www.bibtex.org/
[bibtool]: https://ctan.org/pkg/bibtool
[biome]: https://biomejs.dev/
[black]: https://github.com/python/black
[built-in]: https://neovim.io/doc/user/options.html#'equalprg'
[css]: https://developer.mozilla.org/en-US/docs/Web/CSS
[dockerfile]: https://docs.docker.com/reference/dockerfile/
[dosini]: https://vim.fandom.com/wiki/Dosini_files
[gitconfig]: https://git-scm.com/docs/git-config/2.22.0
[go]: https://golang.org/
[gofmt]: https://golang.org/cmd/gofmt/
[graphql]: https://developer.mozilla.org/en-US/docs/Web/HTML
[html]: https://developer.mozilla.org/en-US/docs/Web/HTML
[htmldjango]: https://docs.djangoproject.com/en/5.1/topics/templates/
[javascript/jsx]: https://developer.mozilla.org/en-US/docs/Web/JavaScript
[jinja.html]: https://jinja.palletsprojects.com/en/3.1.x/
[json]: https://json.org/
[jsonc]: https://komkom.github.io/
[leptosfmt]: https://github.com/bram209/leptosfmt
[lua]: https://www.lua.org/
[make]: https://www.gnu.org/software/make/
[markdown]: https://en.wikipedia.org/wiki/Markdown
[mdformat]: https://github.com/hukkin/mdformat
[mdx]: https://mdxjs.com/
[nginx]: https://www.nginx.com/resources/wiki/start/topics/examples/full/
[nginxfmt]: https://github.com/slomkowski/nginx-config-formatter
[ocaml]: https://ocaml.org/
[ocamlformat]: https://github.com/ocaml-ppx/ocamlformat
[prettier]: https://prettier.io/
[prettier_jinja]: https://github.com/davidodenwald/prettier-plugin-jinja-template
[prettier_prisma]: https://github.com/umidbekk/prettier-plugin-prisma
[prettier_svelte]: https://github.com/UnwrittenFun/prettier-plugin-svelte
[prisma]: https://www.prisma.io/
[python]: https://www.python.org/
[r]: https://www.r-project.org/
[ruff]: https://github.com/astral-sh/ruff
[rust]: https://www.rust-lang.org/
[rustfmt]: https://github.com/rust-lang/rustfmt
[scss]: https://sass-lang.com/
[shfmt]: https://github.com/mvdan/sh
[styler]: https://github.com/r-lib/styler
[stylua]: https://github.com/JohnnyMorganz/StyLua
[svelte]: https://svelte.dev/
[taplo]: https://taplo.tamasfe.dev/cli/usage/formatting.html
[terraform]: https://www.terraform.io/
[terraform_fmt]: https://www.terraform.io/docs/commands/fmt.html
[toml]: https://github.com/toml-lang/toml
[typescript/tsx]: https://www.typescriptlang.org/
[vim.lsp.buf.format]: https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format
[vimscript]: https://vimhelp.org/usr_41.txt.html
[xml]: https://www.w3.org/XML/
[xq]: https://github.com/sibprogrammer/xq
[yaml]: https://yaml.org/
[zig]: https://ziglang.org/
[zig fmt]: https://codeberg.org/ziglang/zig/src/branch/master/src/fmt.zig
[zsh]: https://en.wikipedia.org/wiki/Z_shell
