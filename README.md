# Vim Editorconfig Js

A highly customizable editorconfig plugin for vim that uses a node backend for parsing.

## Features

* easily extend functionality via [custom handlers](#custom-handlers)
* only sets options if the value has changed to prevent full-screen redraws when certain options are set in vim.

### Supported properties

* indent_size
* indent_style
* max_line_length
* trim_trailing_whitespace (trims on buffer write)

## Quick Start

Install [nodejs](https://nodejs.org/en/download/) >= 10.12:

```sh
curl -sL install-node.now.sh/lts | bash
```

For [vim-plug](https://github.com/junegunn/vim-plug) users:

```vim
Plug 'leland-kwong/vim-editorconfig-js', { 'do': './install.sh' }
```

in your `.vimrc` or `init.vim`, then restart Vim and run `:PlugInstall`.

## Usage

As soon as the plugin has been loaded, it will look for the nearest editorconfig on each `BufEnter` autocommand event and trigger all built-in handlers based on the parsed properties.

## Custom handlers

You can hook into the `User OnEditorConfigParse` autocommand event and do custom actions like so:

```vim
au! User OnEditorConfigParse echo g:editorConfig.getConfig(bufnr())
```

## Disable built-in handlers

You can disable the built-in handlers in case you want to handle editorConfig properties entirely on your own.

```vim
let g:editorConfig.enableDefaultHandlers = 0
```
