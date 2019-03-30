if exists("b:did_rcslog_plugin")
finish
endif

" Don't load another filetype plugin for this buffer
let b:did_rcslog_plugin = 1

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

setlocal buftype=nofile noswapfile readonly nomodifiable bufhidden=wipe
setlocal foldexpr=RCSFoldLog() foldmethod=expr

"reset &cpo back to users setting
let &cpo = s:save_cpo

" Template From: https://github.com/dahu/Area-41/
" vim: set sw=2 sts=2 et fdm=marker:
