" rlog functions
function! rcs#log#get_id(line) abort
    " let l:position = getcurpos()

    call cursor(a:line, 0)
    let l:back    = search('^-\+\nrevision \d\+\.\d\+', 'bWn')
    let l:forward = search('^-\+$', 'Wn')

    " call setpos( l:position )

    if l:back > 0 
        \ && a:line >= l:back 
        \ && a:line <= l:forward 
        \ && getline('.') !~# '^-\+$'

        let l:line = getline(l:back + 1)
        let l:id   = substitute(l:line, 'revision \(\d\+\.\d\+\).*', '\1', '')

        return [l:id, l:back, l:forward]
    else
        return [-1, -1, -1]
    endif
endfunction
