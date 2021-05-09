# Vim Editorconfig Js

An editorconfig plugin for vim that uses a node backend for parsing.

## Rationale

[editorconfig-vim](https://github.com/editorconfig/editorconfig-vim) is a great plugin except it causes a fullscreen redraw when certain options are set. This plugin circumvents that issue by only setting an option if the new value is different.

Additionally, by leveraging the node ecosystem, we can easily get the latest parser updates.

## Usage

As soon as the plugin has been loaded, it will look for the nearest editorconfig each on `BufEnter` autocommand event.

### Supported properties

* indent_size
* indent_style
* max_line_length
* trim_trailing_whitespace (trims on buffer write)

## Install with [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'leland-kwong/vim-editorconfig-js', { 'do': './install.sh' }
```
