" =========
"  Globals
" =========
let s:editorConfigPropHandler = {}

fun! EditorConfigShouldParse()
  let l:shouldParse = &buftype == ''
    \ && &filetype != 'gitcommit'
    \ && !&readonly
  return l:shouldParse
endfun

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

fun! s:editorConfigPropHandler.indent_size(val)
  call s:SetBufVar('&tabstop', a:val)
  call s:SetBufVar('&shiftwidth', a:val)
endfun

fun! s:editorConfigPropHandler.indent_style(val)
  if a:val == 'space'
    setlocal expandtab
  endif

  if a:val == 'tab'
    setlocal noexpandtab
  endif
endfun

fun! s:editorConfigPropHandler.max_line_length(val)
  call s:SetBufVar('&textwidth', a:val)
endfun

fun! s:TrimTrailingWhitespace()
  let l:config = getbufvar(bufnr(), 'editorConfig', {})

  if !get(l:config, 'trim_trailing_whitespace', 0)
    return
  endif

  let s:trimSave = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(s:trimSave)
endfun

fun! s:EditorConfigSetOptions(chan, data)
  let l:parsedConfig = json_decode(a:data)

  if exists('l:parsedConfig.err')
    echoerr l:parsedConfig.err
    return
  endif

  call setbufvar(bufnr(), 'editorConfig', l:parsedConfig)

  for k in keys(l:parsedConfig)
    let l:val = l:parsedConfig[k]

    if exists('s:editorConfigPropHandler[k]')
      call s:editorConfigPropHandler[k](l:val)
    endif
  endfor
endfun

fun! s:EditorConfigParse()
  if !v:vim_did_enter || !EditorConfigShouldParse()
    return
  endif

  let l:plugDir = expand('<sfile>:p:h')
  let l:fileToCheck = expand('%:p')
  let l:extension = expand('%:e')

  " this is empty for certain buffers like the cmdline history
  if empty(l:fileToCheck) || empty(l:extension)
    return
  endif

  let l:shellCmd = join([
    \'cd '.l:plugDir,
    \'&&',
    \'node editorconfig-vim.js '.l:fileToCheck
  \])
  let l:jobCmd = ['/usr/bin/bash', '-c', l:shellCmd]

  " cancel previous job so we don't set options
  " for the wrong buffer.
  let l:shouldCancelJob = exists('s:curJob')
    \ && job_status(s:curJob) == 'run'
  if l:shouldCancelJob
    call job_stop(s:curJob)
  endif

  let s:curJob = job_start(l:jobCmd,
    \ #{callback: function('s:EditorConfigSetOptions')})
endfun

augroup EditorConfig
  au!
  au BufWritePre * call s:TrimTrailingWhitespace()
  au VimEnter,BufEnter *
    \ call s:EditorConfigParse()
augroup END
