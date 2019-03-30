
function! rcs#alert(message) abort
    echohl ErrorMsg
    echomsg a:message
    echohl None
endfunction

function! rcs#shell_escape(str) " {{{2
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

function! rcs#print_error(cmd, error)
    call rcs#alert( 'Nonzero exit status from: ' . a:cmd )
    echo a:error
    let v:errmsg = a:error
endfunction

