if exists('b:did_rcslog_plugin')
    finish
endif

" Don't load another filetype plugin for this buffer
let b:did_rcslog_plugin = 1

" Allow use of line continuation.
let s:save_cpo = &cpoptions
set cpoptions&vim

setlocal buftype=nofile noswapfile readonly nomodifiable bufhidden=wipe
setlocal foldexpr=RCSFoldLog() foldmethod=expr

nnoremap <buffer> <nowait> q <C-w>c
nnoremap <buffer> <space> <C-f>
nnoremap <buffer> b <C-b>
nnoremap <silent> <buffer> J :if search('^-\+\nrevision \d\+\.\d\+', 'W')<bar>exe 'normal! j'<bar>endif<CR>
nnoremap <silent> <buffer> K :call search('^revision \d\+\.\d\+', 'Wb')<CR>
      \:call search('^-\+\nrevision \d\+\.\d\+', 'Wb')<CR>j

"reset &cpo back to users setting
let &cpoptions = s:save_cpo
