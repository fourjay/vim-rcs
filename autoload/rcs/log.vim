" rlog functions
function! rcs#log#get_id(line) abort

    call cursor(a:line, 0)
    let l:chunk_start    = search('^-\+\nrevision \d\+\.\d\+', 'bWn')
    let l:chunk_end = search('^[=-]\+$', 'Wn')
    " echom 'a:line ' . a:line . ' l:chunk_end ' . l:chunk_end . ' l:chunk_start ' . l:chunk_start

    if l:chunk_start > 0 
        " test
        \ && a:line >= l:chunk_start 
        \ && a:line <= l:chunk_end
        \ && getline('.') !~# '^-\+$'

        let l:line = getline(l:chunk_start + 1)
        let l:id   = substitute(l:line, 'revision \(\d\+\.\d\+\).*', '\1', '')

        return [l:id, l:chunk_start, l:chunk_end]
    else
        return [-1, -1, -1]
    endif
endfunction
