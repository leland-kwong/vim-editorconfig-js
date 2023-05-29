let s:bashPath = trim(system('which bash'))
let s:plugDir = substitute(
  \expand('<sfile>:p:h'), '/plugin', '', '')
let g:editorConfig = #{
  \enableDefaultHandlers: 1
\}

let s:editorConfigPropHandler = {}

fun! g:editorConfig.getConfig(buf)
  return getbufvar(a:buf, 'editorConfig', {})
endfun

fun! s:EditorConfigShouldParse()
  return v:vim_did_enter
    \ && &buftype == ''
    \ && &filetype != 'gitcommit'
    \ && !&readonly
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
  let l:config = g:editorConfig.getConfig(bufnr())

  if !get(l:config, 'trim_trailing_whitespace', 0)
    return
  endif

  let s:trimSave = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(s:trimSave)
endfun

fun! s:EditorConfigParseSuccess(chan, data)
  let l:parsedConfig = json_decode(a:data)

  call setbufvar(bufnr(), 'editorConfig', l:parsedConfig)
  do User OnEditorConfigParse
endfun

fun! s:EditorConfigParseError(chan, errmsg)
  echoerr '[editorConfig parse error] '.a:errmsg
endfun

fun! s:EditorConfigParse()
  if !s:EditorConfigShouldParse()
    return
  endif

  let l:fullPathToCheck = expand('%:p')
  " this is empty for certain buffers like the cmdline history
  let l:file = expand('%:t')

  if empty(l:fullPathToCheck) || empty(l:file)
    return
  endif

  " cancel previous job so we don't set options
  " for the wrong buffer.
  let l:shouldCancelJob = exists('s:curJob')
    \ && job_status(s:curJob) == 'run'
  if l:shouldCancelJob
    call job_stop(s:curJob)
  endif

  let l:shellCmd = join([
    \'cd '.s:plugDir,
    \'&&',
    \'node editorconfig-vim.js '.'"'.l:fullPathToCheck.'"'
  \])
  let l:jobCmd = [s:bashPath, '-c', l:shellCmd]
  let s:curJob = job_start(l:jobCmd,
    \ #{out_cb: function('s:EditorConfigParseSuccess')
    \  ,err_cb: function('s:EditorConfigParseError')})
endfun

fun! s:EditorConfigSetOptions()
  if !g:editorConfig.enableDefaultHandlers
    return
  endif

  let l:parsedConfig = g:editorConfig.getConfig(bufnr())

  for k in keys(l:parsedConfig)
    let l:val = l:parsedConfig[k]

    if exists('s:editorConfigPropHandler[k]')
      call s:editorConfigPropHandler[k](l:val)
    endif
  endfor
endfun

augroup EditorConfig
  au!
  au User OnEditorConfigParse call s:EditorConfigSetOptions()
  au BufWritePre * call s:TrimTrailingWhitespace()
  au VimEnter,BufEnter *
    \ call s:EditorConfigParse()
augroup END
