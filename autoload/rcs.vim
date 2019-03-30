
function! rcs#alert(message) abort
    echohl ErrorMsg
    echomsg a:message
    echohl None
endfunction

function! rcs#shell_escape(str) abort
    if exists('*shellescape')
        return shellescape(a:str)
    else
        if has('unix')
            return "'" . substitute(a:str, "'", "'\\\\''", 'g') . "'"
        else
            " Don't know how to properly escape for 'doze, so don't bother:
            return a:str
        endif
    endif
endfunction

function! rcs#print_error(cmd, error) abort
    call rcs#alert( 'Nonzero exit status from: ' . a:cmd )
    echo a:error
    let v:errmsg = a:error
endfunction

let s:only_print = 0
function! rcs#only_print_command(...) abort
    if a:0 != 0
        let s:only_print = a:1
    endif
    return s:only_print
endfunction

function! rcs#do_command(cmd) abort
    if rcs#only_print_command() != 0
        return a:cmd
    else
        let l:rcs_output = system( a:cmd )
    endif
    if v:shell_error
        call rcs#print_error(a:cmd, l:rcs_output)
    endif
endfunction

function! rcs#do_privileged_command(cmd) abort
    let sudo = ''
    if exists('b:sudo')
        let sudo = b:sudo
    endif
    let l:full_cmd  = sudo . a:cmd
    call rcs#do_command( l:full_cmd )
endfunction
