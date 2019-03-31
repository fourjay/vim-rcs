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

" function! s:CheckForLock(file) abort
function! rcs#log#get_locker(file) abort
    " let rlog_out = split(system('rlog -L -h ' . a:file), '\n')
    let l:rlog_output = rcs#do_command('rlog -L ' . a:file)
    let l:rlog_lines = split(l:rlog_output,  "\n")
    if len(l:rlog_lines) == 0
        return ''
    endif

    let locker = ''
    let index = 0
    for l:line in l:rlog_lines
        if l:line =~? '\slocked by: \S\+;'
            let l:locker = substitute(l:line, '.*\slocked by: ', '', '')
            let l:locker = substitute(l:locker, ';.*', '', '')
            return l:locker
        endif
    endfor
    return ''
endfunction
