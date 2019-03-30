
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

function! rcs#do_command(cmd, file) abort
    let sudo = ''
    if exists('b:sudo')
        let sudo = b:sudo
    endif
    let full_cmd  = sudo . a:cmd . ' ' . rcs#shell_escape(a:file)
    let RCS_Out = system( full_cmd )
    if v:shell_error
        call rcs#print_error(full_cmd, RCS_Out) 
    endif
endfunction
