" generic command object
function! rcs#command#new(command) abort
    let l:command = {
               \     'command' : a:command,
               \     'force'   : '',
               \     'mode'    : '',
               \     'sudo'    : '',
               \ }
    if exists('b:sudo') 
        let l:command.sudo = b:sudo
    endif

    function! l:command.string() abort dict
        return self.sudo . ' '
                    \ . self.command . ' '
                    \ . self.force . ' '
                    \ . self.mode . ' '
    endfunction

    return l:command
endfunction
