" my own editorconfig parser since the 'official one'
" causes vi to flicker whenever you refresh. Also, we
" should be able to make it more functional so that it
" runs a callback with the parsed document. This way
" we can separate out the parser from the side-effects.

let s:propHandler = {}

fun! s:SetBufVar(name, val)
  if getbufvar(bufnr(), a:name) != a:val
    call setbufvar(bufnr(), a:name, a:val)
  endif
endfun

fun! s:propHandler.indent_size(val)
  call s:SetBufVar('&tabstop', a:val)
  call s:SetBufVar('&shiftwidth', a:val)
endfun

fun! s:propHandler.indent_style(val)
  if a:val == 'space'
    set expandtab
  endif

  if a:val == 'tab'
    set noexpandtab
  endif
endfun

fun! s:ClearBuffer(bufnr)
  silent call deletebufline(a:bufnr, 1, 99) 
endfun

fun! EditorConfigJobCallback(chan, data)
  call s:ClearBuffer(29)
  call setbufline(29, 1, '# editorconfig settings')

  let l:parsed = json_decode(a:data)
  let l:file = glob('~/tmp/term.log')
  let l:lineNum = 2

  for k in keys(l:parsed)
    let l:val = l:parsed[k]

    if exists('s:propHandler[k]')
      call s:propHandler[k](l:val)
      call setbufline(29, l:lineNum, k.': '.l:val)
      let l:lineNum = l:lineNum + 1
    endif
  endfor
endfun

fun! s:propHandler.max_line_length(val)
  call s:SetBufVar('&textwidth', a:val)
endfun

fun! EditorConfigParse(fullPath)
  let l:isEditableTextBuffer = &buftype == ''
  if !l:isEditableTextBuffer
    return
  endif

  let s:job = job_start(['/usr/bin/zsh', '-c', 'cd ~/tmp/editorconfig-parser && node editorconfig-vim.js '.a:fullPath], { 
        \'callback': 'EditorConfigJobCallback' })
endfun

augroup editorconfigHotReload
  autocmd!
  autocmd BufWritePost <buffer> source %
augroup END

autocmd! WinEnter,BufWinEnter * call EditorConfigParse(expand('%:p'))
