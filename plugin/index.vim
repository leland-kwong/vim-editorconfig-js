" =========
"  Globals
" =========
let g:editorConfigPropHandler = {}
fun! EditorConfigShouldParse()
  let l:shouldParse = &buftype == '' && !&readonly
  return l:shouldParse
endfun

let s:ready = 0

" A wrapper around vim's built-in `setbufvar` that only sets
" the option if there is a difference between current and
" new value. This prevents the situation with certain
" options that cause a full-screen redraw whenever they are
" set.
fun! s:SetBufVar(name, val)
  if getbufvar(bufnr(), a:name) != a:val
    call setbufvar(bufnr(), a:name, a:val)
  endif
endfun

fun! g:editorConfigPropHandler.indent_size(val)
  call s:SetBufVar('&tabstop', a:val)
  call s:SetBufVar('&shiftwidth', a:val)
endfun

fun! g:editorConfigPropHandler.indent_style(val)
  if a:val == 'space'
    setlocal expandtab
  endif

  if a:val == 'tab'
    setlocal noexpandtab
  endif
endfun

fun! g:editorConfigPropHandler.max_line_length(val)
  call s:SetBufVar('&textwidth', a:val)
endfun

fun! s:EditorConfigSetOptions(chan, data)
  let l:parsedConfig = json_decode(a:data)

  for k in keys(l:parsedConfig)
    let l:val = l:parsedConfig[k]

    if exists('g:editorConfigPropHandler[k]')
      call g:editorConfigPropHandler[k](l:val)
    elseif exists('g:editorConfigPropHandler[k]')
      call g:editorConfigPropHandler[k](l:val)
    endif
  endfor
endfun

fun! s:EditorConfigParse()
  if !s:ready || !EditorConfigShouldParse()
    return
  endif

  let l:plugDir = expand('<sfile>:p:h')
  let l:fileToCheck = expand('%:p')
  let l:shellCmd = join([
    \'cd '.l:plugDir,
    \'&&',
    \'node editorconfig-vim.js '.l:fileToCheck
  \])
  let l:jobCmd = ['/usr/bin/bash', '-c', l:shellCmd]

  if exists(s:curJob) && job_status(s:curJob) == 'run'
    echom 'running job'
  endif

  let s:curJob = job_start(l:jobCmd,
    \ #{callback: function('s:EditorConfigSetOptions')})
endfun

augroup VimEditorconfigJsSetReady
  autocmd!
  " on initial load of vim, the `BufEnter` command runs
  " before `VimEnter` which causes the `l:plugDir` to be set
  " to a value of `command line..script` which is an invalid
  " file directory name.
  autocmd VimEnter * let s:ready = 1
augroup END

augroup VimEditorconfigJs
  autocmd!
  autocmd VimEnter,BufEnter *
    \ call s:EditorConfigParse()
augroup END
