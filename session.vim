if exists('g:loaded_session')
  finish
endif
let g:loaded_session = 1

command! SessionList call session#sessions()

let s:sep = fnamemodify('.', ':p')[-1:]

function! session#create_session(file) abort
  execute 'mksession!' join([g:session_path, a:file], s:sep)

  " re draw
  redraw
  echo 'session.vim: created'
endfunction

function! session#load_session(file) abort
  execute 'source' join([g:session_path, a:file], s:sep)
endfunction

function! s:echo_err(msg) abort
  echohl ErrorMsg
  echomsg 'session.vim:' a:msg
  echohl None
endfunction

function! s:files() abort
  let session_path = get(g:, 'session_path', '')

  if session_path is# ''
    call s:echo_err('g:session_path is empty')
    return []
  endif

  let Filter = { file -> !isdirectory(session_path . s:sep . file) }

  return readdir(session_path, Filter)
endfunction

let s:session_list_buffer = 'SESSIONS'

function! session#sessions() abort
  let files = s:files()
  if empty(files)
    return
  endif

  if bufexists(s:session_list_buffer)
    let winid = bufwindid(s:session_list_buffer)
    if winid isnot# -1
      call win_gotoid(winid)

    else
      execute 'sbuffer' s:session_list_buffer
    endif
  else
    execute 'new' s:session_list_buffer

    set buftype=nofile

    nnoremap <silent> <buffer>
      \ <Plug>(session-close)
      \ :<C-u>bwipeout!<CR>

    nnoremap <silent> <buffer>
      \ <Plug>(session-open)
      \ :<C-u>call session#load_session(trim(getline('.')))<CR>
    
    nmap <buffer> q <Plug>(session-close)
    nmap <buffer> <CR> <Plug>(session-open)
  endif

  %delete _
  call setline(1, files)
endfunction
