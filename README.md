# Vim Editorconfig Js

An editorconfig plugin for vim that uses a node backend for parsing.

## Rationale

[editorconfig-vim](https://github.com/editorconfig/editorconfig-vim) is a great plugin except it causes a fullscreen redraw when certain options are set. This plugin circumvents that issue by only setting an option if the new value is different.

Additionally, by leveraging the node ecosystem, we can easily get the latest parser updates.

## Usage

As soon as the plugin has been loaded, it will look for the nearest editorconfig each on `BufEnter` autocommand event.

### Install with [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'leland-kwong/vim-editorconfig-js', { 'do': './install.sh' }
```

### Custom parser functions

You can define a custom editorconfig property handler like so:

```vim
" handler for `max_line_length` property
fun! g:editorConfigPropHandler.max_line_length(val)
  "...your code"
endfun
```
