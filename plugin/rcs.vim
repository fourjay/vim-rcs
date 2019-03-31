" vim600:fdm=marker:fdc=3:cms=\ "\ %s:fml=2:tw=76:
"
" ----------------------------------------------------------------------------
" rcs.vim -- Automatically handle RCS controlled files.
"
" Author:      Christian J. Robinson <heptite@gmail.com>
" URL:         http://christianrobinson.name/vim/
" Last Change: April 27, 2010
" Version:     0.15.2
"
" Copyright (C) 2002-2010 Christian J. Robinson <heptite@gmail.com>
" Distributed under the terms of the Vim license.  See ":help license".
"
" Install Details: -----------------------------------------------------------
"
" Make the following directories (this script will probably not work on
" non-Unix systems):
"   ~/.vim/plugin
"   ~/.vim/doc
"
" Place this script in the plugin directory, then start Vim. The
" documentation should automatically be created. Then you can do:
"   :help rcs.txt
"
" ----------------------------------------------------------------------------
"
" TODO:  Allow diffing between two arbitrary revisions, both with :RCSdiff
"        and from the log display.
"

if v:version < 700
	call rcs#alert('Vim 7.0 or greater is needed to run ' . expand('<sfile>:p') )
	finish
endif

if ! has('unix')
	call rcs#alert( expand('<sfile>:p') . 'will probably not work correctly on non-Unix systems' )
	finish
endif

let s:savecpo = &cpoptions
set cpoptions&vim

if exists("g:loaded_rcs_plugin")
	let &cpoptions = s:savecpo
	unlet s:savecpo
	finish
endif
let g:loaded_rcs_plugin = 1

let b:sudo = ''
if exists('g:sudo_rcs_plugin')
    let b:sudo = 'sudo '
endif

" Autocommands: {{{1
 " augroup RCS_plugin
	 " au!
	 " autocmd BufUnload * nested call s:BufUnload()
 " augroup END

" Commands: {{{1
command!          RCSdiff call s:Diff(expand("%:p"))
command!          RCSlog  call s:ViewLog(expand("%:p"))
command! -complete=custom,<SID>rcscomplete -nargs=? RCSco   call s:CheckOut(expand("%:p"), <f-args>)
command! -nargs=? RCSci   call s:CheckIn(expand("%:p"))
function! s:rcscomplete(...) abort
    return "w\nro\n"
endfunction

command! RCSsudo let b:sudo="sudo "
command! RCSwork call s:CheckIn(expand("%:p"), "lock" )

command! RCSnostrict :call system( b:sudo . " rcs -U " . expand("%s:p") )

 " command! -complete=custom,<SID>short_complete -nargs=? RCS execute "RCS" . expand('\<args>')

function! s:short_complete(...) abort
    return "diff\nlog\nco\nci\nsudo\nwork\nnostrict\n"
endfunction


" Functions: {{{1

function! s:FileChangedRO() abort
	if (filereadable(expand('<afile>:p:h') . '/RCS/' . expand('<afile>:t') . ',v')
				\ || filereadable(expand('<afile>') . ',v'))
				\ && (confirm('This is a read-only RCS controlled file, check out?', '&Yes\n&No', 1, 'Q') == 1)
		call s:CheckOut(expand('<afile>:p'), 1)
		silent! foldopen!
	endif
endfunction

function! s:BufUnload() abort
	if getbufvar(expand('<afile>:p'), 'RCS_CheckedOut') != ''
				\ && (getbufvar(expand('<afile>:p'), 'RCS_CheckedOut') == expand('<afile>:p'))
				\ && (confirm(expand('<afile>:t') . ' is an RCS controlled file checked out by Vim.\nCheck back in?', '&Yes\n&No', 1, 'Q') == 1)
		call s:CheckIn(expand('<afile>:p'), 0)
	endif
endfunction

function! s:Diff(file) abort
	if len(s:WinLocalVars('&diff')) > 0
		call rcs#alert( 'It appears Vim is already running a diff, close those buffers first.' )
		return 0
	endif

	let rcs_diff_name = '[Previous version of ' . fnamemodify(a:file, ':t') . ']'

	if bufnr('^\V' . rcs_diff_name) != -1
                call rcs#alert( 'Already viewing differences for the current file.')
		return
	endif

	let rcs_diff_name = escape(rcs_diff_name, ' \')
	let rcs_diff_file = tempname()
	let curbuf        = bufnr(a:file)
	let filetype      = getbufvar(a:file, '&filetype')
	let syntax        = getbufvar(a:file, '&syntax')
	let wrap          = getbufvar(a:file, '&wrap')
	let foldcolumn    = getbufvar(a:file, '&foldcolumn')
	let foldmethod    = getbufvar(a:file, '&foldmethod')
	let scrollopt     = getbufvar(a:file, '&scrollopt')
	let scrollbind    = getbufvar(a:file, '&scrollbind')

	silent call system( b:sudo . 'co -p ' . rcs#shell_escape(a:file) . ' > ' . rcs#shell_escape(rcs_diff_file) . ' 2> /dev/null')
	exe 'silent vertical rightbelow diffsplit ' . rcs_diff_file
	exe 'silent file ' . rcs_diff_name
	exe 'silent bwipe! ' . rcs_diff_file
	call delete(rcs_diff_file)
	exe 'setlocal filetype=' . filetype . ' syntax=' . syntax
	setlocal buftype=nofile noswapfile foldmethod=diff readonly nomodifiable
	setlocal bufhidden=wipe
        nnoremap <buffer> <nowait> q :bwipe<cr>

	exe 'autocmd! BufDelete <buffer> ' .
		\ 'call setwinvar(bufwinnr(' . curbuf . '), "&diff", "0") | '
		\ 'call setwinvar(bufwinnr(' . curbuf . '), "&wrap", "' . wrap . '") | '
		\ 'call setwinvar(bufwinnr(' . curbuf . '), "&scrollbind", "' . scrollbind . '") | '
		\ 'call setwinvar(bufwinnr(' . curbuf . '), "&scrollopt", "' . scrollopt . '") | '
		\ 'call setwinvar(bufwinnr(' . curbuf . '), "&foldcolumn", "' . foldcolumn . '") | '
		\ 'call setwinvar(bufwinnr(' . curbuf . '), "&foldmethod", "' . foldmethod . '") | '
		\ 'redraw!'

	normal! zX
	wincmd p
	normal! zX
endfunction

function! s:CheckOut(file, ...) abort
	let l:mode = ''

        if a:0 == 0
            let l:mode = 'w'
        endif
	if a:0 == 1 || l:mode ==? 'w'
		let l:mode = 'l'
	elseif l:mode !=? 'w' && l:mode !=? 'ro' && l:mode !=? 'r'
		call rcs#alert( 'Unknown argument: ' . l:mode . '  Valid arguments are "r"/"ro" or "w".' )
		return
	endif

	let locker = rcs#log#get_locker(a:file)

	if locker != '' && locker != $LOGNAME . 'a'
		let confirm_promt =                 a:file . " appears to have been locked by username '" . locker . "'.\n"
                let confirm_promt = confirm_promt . "Force a check out anyway (this could cause loss of data)?"
		if confirm(confirm_promt, "&Yes\n&No", 2, 'W') == 2
			return
		else
			let l:mode = '-f ' . l:mode
			let RCS_Out = system(b:sudo . 'co ' . l:mode . rcs#shell_escape(a:file))
                        autocmd <buffer>  BufUnload * nested call s:BufUnload()
		endif
	elseif filewritable(a:file)
		if confirm(a:file . " is writable (locked).\nForce a check out of previous version (your changes will be lost)?", "&Yes\n&No", 2, 'W') == 1
			let l:mode = '-f ' . l:mode
			let RCS_Out = system(b:sudo . 'co ' . l:mode . rcs#shell_escape(a:file))
		elseif l:mode == 1 || l:mode == 'w' && confirm('Tell Vim this is a controlled RCS file anyway?', "&Yes\n&No", 1, 'Q') == 1
			let b:RCS_CheckedOut = a:file
			return
		else
			return
		endif
	else
		silent! exe '!rcsdiff ' . rcs#shell_escape(a:file) . ' >/dev/null 2>&1'
		if v:shell_error > 0 && confirm(a:file . " appears to have been modified without being checked out writable (locked) first.\nCheck out anyway (changes, if any, will be lost)?", "&Yes\n&No", 2, 'W') == 2
			return

		else
			let co_cmd = b:sudo . 'co ' . l:mode . rcs#shell_escape(a:file)
			let RCS_Out = system(co_cmd)
		endif
	endif

	if v:shell_error
		call rcs#print_error( co_cmd, RCS_Out)
		return 1
	endif

	if l:mode == 1 || l:mode == 'w'
		let b:RCS_CheckedOut = a:file
	elseif exists('b:RCS_CheckedOut')
		let b:RCS_CheckedOut = ''
	endif

	let eventignore_save = &eventignore
	let &eventignore = 'BufUnload,FileChangedRO'
	let l = line('.')
	let c = col('.')
	execute 'silent e!'
	call cursor(l, c)
	let &eventignore = eventignore_save
        redraw!
endfunction

function! s:open_commit(cmd) abort
    let ci_cmd = a:cmd
    let log_buf_name = '__RCS_COMMIT_MSG__'
    let log_win_height = 5
    let rcs_file = expand('%:p')
    call s:set_rcsfilename( rcs_file )
    let b:rcs_filename = rcs_file
    execute 'keepalt ' . log_win_height . 'split ' . log_buf_name
    if exists( '#User#RCSnewBufferEvent' )
        doautocmd User RCSnewBufferEvent
    endif
    let rcs_file = expand('%:p')
    call append(0, '# RCS - write to commit')
    call append(0, '# RCS - lines beginning with # RCS will be stripped')
    setlocal textwidth=70
    setlocal noswapfile
    setlocal buftype=acwrite
    setlocal bufhidden=wipe
    setlocal filetype=rcscommit
    setlocal syntax=conf
    nnoremap <buffer> ZZ :write<cr>
    let b:rcs_filename = rcs_file
    let b:ci_cmd = ci_cmd
    autocmd BufWriteCmd <buffer> call s:write_commit()
    autocmd BufWritePost <buffer> call s:rcs_write_buffer_cleanup( )
endfunction

function! s:write_commit() abort
     " echom 'in write_commit ' . b:ci_cmd
    let msg_a = getbufline( '%', 1, '$' )
    let msg_a = filter(msg_a, 'v:val !~ "^\s*#[ ]*RCS"')
    let msg = join( msg_a, "\r" )
    let msg = rcs#shell_escape(msg)
    let msg = substitute(msg, '\\'."\n", "\n", 'g')
    call rcs#do_privileged_command( b:ci_cmd . ' -m' . msg . ' ' . rcs#shell_escape( s:get_rcsfilename()) )
    call s:rcs_write_buffer_cleanup()
endfunction

function! s:rcs_write_buffer_cleanup() abort
    let rcs_cleanup_window = bufnr('__RCS_COMMIT_MSG__')
    let current_window = bufnr('%')
    if rcs_cleanup_window != ''
        if rcs_cleanup_window != current_window
            execute  rcs_cleanup_window . 'wincmd w'
        endif
        setlocal bufhidden=wipe
        setlocal buftype=nofile
        bdelete
    endif
    if exists( '#User#RCSciEvent' )
        doautocmd User RCSciEvent
    endif
endfunction

let s:rcs_filename = ''
function! s:set_rcsfilename(filename) abort
    let s:rcs_filename = a:filename
endfunction

function! s:get_rcsfilename() abort
        return s:rcs_filename
endfunction

function! s:CheckIn(file, ...) abort
	if (getbufvar(a:file, '&modified') == 1)
				\ && (confirm(fnamemodify(a:file, ':t') . " has unwritten changes, check in anyway?", "&Yes\n&No", 2, "Q") != 1)
		return
	endif

        let lock_flag = ''
        if a:0 > 0
            let lock_flag = " -l "
        endif

	call setbufvar(a:file, 'RCS_CheckedOut', '')

         " let ci_cmd = b:sudo . " ci -f " . lock_flag . " -m" . fullrlog  . " " . rcs#shell_escape(a:file)
        let ci_cmd = b:sudo . " ci -f " . lock_flag
        call s:open_commit(ci_cmd)
        return
	let RCS_Out = system( ci_cmd )
        if v:shell_error
            call rcs#print_error( ci_cmd, RCS_Out )
        else
            if exists( '#User#RCSciEvent' )
                doautocmd User RCSciEvent
            endif
        endif

        if lock_flag == ''
            let co_cmd = b:sudo . 'co -u ' . rcs#shell_escape(a:file)
            let RCS_Out = system(co_cmd)
            if v:shell_error 
                call rcs#print_error( co_cmd, RCS_Out ) 
            endif
        endif

	if a:0 >= 1 && a:1 == 0
		return
	endif

	let eventignore_save = &eventignore
	let &eventignore = 'BufUnload,FileChangedRO'
	let l = line(".")
	let c = col(".")
	execute "silent e!"
	call cursor(l, c)
	let &eventignore = eventignore_save
        redraw!
endfunction

function! s:ViewLog(file) abort
	let file_escaped=escape(fnamemodify(a:file, ':t'), ' \')

        " store b:sudo for new window
        let l:do_sudo = rcs#get_sudo()
	exe 'silent topleft new [RCS\ log\ for\ ' . file_escaped . ']'
	let b:rcs_filename = a:file
        " re-register b:sudo
        let b:sudo = l:do_sudo

	call s:load_rcs_log(a:file)

        set filetype=rlog

	normal! zR

	nnoremap <silent> <buffer> <cr> :call <SID>EditLogItem()<CR>
	nnoremap <silent> <buffer> d :call <SID>LogDiff()<CR>
	nnoremap <silent> <buffer> <c-l> <c-l>:call <SID>load_rcs_log(b:rcs_filename)<CR>

	autocmd CursorMoved <buffer> call s:LogHighlight()
endfunction

function! s:load_rcs_log(file) abort
	setlocal noreadonly modifiable
	silent! 1,$delete
	execute 'silent 0r !rlog ' . rcs#shell_escape(a:file)
	let keys = [ '+++ HELP: [JK] navigate log sections | <Cr> edit log section | [d] diff +++' ]
	call append(0, keys)
	setlocal readonly nomodifiable
	1 " Go to the first line in the file.
	silent! goto 1

	exe 'syntax match rcslogKeys   =^\%<' . (len(keys) + 1) . 'l+++ .\+ +++$='
endfunction

function! RCSFoldLog() abort
	if getline(v:lnum) =~# '^+++ .\+ +++$'
		return 1
	endif
	if getline(v:lnum) == '' && getline(v:lnum - 1) =~ '^+++ .\+ +++$'
		return 0
	endif
	if getline(v:lnum) =~ '^-\+$'
		return '>1'
	endif

	return '='
endfunction

function! s:LogHighlight() abort
	let curline = line('.')
	let idarr = rcs#log#get_id(curline)

	if idarr[0] != -1
		if exists('b:rcsmatchid')
			silent! call matchdelete(b:rcsmatchid)
			call matchadd('rcslogCurrent', '^\%' . idarr[1] . 'l\_.\+\%' . idarr[2] . 'l-\+', 20, b:rcsmatchid)
		else
			let b:rcsmatchid = matchadd('rcslogCurrent', '^\%' . idarr[1] . 'l\_.\+\%' . idarr[2] . 'l-\+', 20)
		endif
	else
		silent! call matchdelete(b:rcsmatchid)
	endif

	" A faster/easier way?:
	"  /^-\+\(\n\(-\+\)\@!.\+\)*\%#.*\(\n\(-\+\)\@!.\+\)*
endfunction

function! s:LogDiff() abort
	if ! exists('b:rcs_filename')
		call rcs#alert( 'Cannot determine the filename associated with the current log' )
		return 0
	endif

	if len(s:WinLocalVars('&diff')) > 0
		call rcs#alert( 'It appears Vim is already running a diff, close those buffers first.' )
		return 0
	endif

	let rcs_filename = b:rcs_filename

	let curline = line('.')
	let idarr1 = rcs#log#get_id(curline)

	if idarr1[0] != -1
		let idarr2 = rcs#log#get_id(idarr1[2] + 1)
	endif

	if idarr1[0] == -1 || idarr2[0] == -1
		call rcs#alert( "Can't determine the revision IDs to diff" )
		return 0
	endif

	let file_escaped=escape(fnamemodify(rcs_filename, ':t'), ' \')

	exe 'silent topleft new [' . file_escaped . ', revision ' . idarr2[0] . ']'
	silent exe 'read !co -p -r' . idarr2[0] . ' ' . rcs#shell_escape(rcs_filename) . ' 2>/dev/null'
	diffthis
	setlocal buftype=nofile noswapfile readonly nomodifiable bufhidden=wipe
        nnoremap <buffer> <nowait> q :bwipe<Cr>
         " nnoremap <buffer> <nowait> j :wincmd j<cr> | :wincmd j

	exe 'silent vertical rightbelow new [' . file_escaped . ', revision ' . idarr1[0] . ']'
	silent exe 'read !co -p -r' . idarr1[0] . ' ' . rcs#shell_escape(rcs_filename) . ' 2>/dev/null'
	diffthis
	setlocal buftype=nofile noswapfile readonly nomodifiable bufhidden=wipe
        nnoremap <buffer> <nowait> q :bwipe<Cr>
        nnoremap <buffer> <nowait> j :wincmd j<cr>

	wincmd p
        nnoremap <buffer> <nowait> q :wincmd l<cr>:bwipe<cr>:bwipe<cr>
	wincmd _
	1
endfunction

function! s:EditLogItem() abort
	if ! exists('b:rcs_filename')
		call rcs#alert( "Can't determine the filename associated with the current log" )
		return 0
	endif

	let rcs_filename = b:rcs_filename

        " add support for sudo grab buffer variable for later
        " re-registration
        let do_sudo = b:sudo

	let curline = line('.')
	let idarr = rcs#log#get_id(curline)

	if idarr[0] != -1
		let fname =  '[Log entry for ' . fnamemodify(rcs_filename, ':p:t') . ' revision ' . idarr[0] . ']'

		if bufloaded(fname)
			call rcs#alert( 'A buffer for that log message already exists' )
			return 0
		endif

		execute 'new ' . escape(fname, ' \')
		setlocal buftype=acwrite bufhidden=wipe
		let b:rcs_id       = idarr[0]
		let b:rcs_filename = rcs_filename
                " re-register b:sudo flag for edit window
                let b:sudo = do_sudo
		silent! execute 'read !rlog -r' . idarr[0] . ' ' . rcs#shell_escape(rcs_filename)
		silent! 1,/^revision .\+\ndate: \d\{4\}\/\d\d\/\d\d \d\d:\d\d:\d\d.*/+1 delete
		silent! $delete
		call append(0, ['+++ Change the log message below this line and write+quit +++', ''])
		setlocal nomodified

		syntax match rcslogKeys =^\%<2l+++ .\+ +++$=
		highlight default link rcslogKeys Todo

		autocmd BufWriteCmd <buffer> call s:SaveLogItem()
	else
		call rcs#alert( "The cursor isn't within a log section" )
		return 0
	endif
endfunction


function! s:SaveLogItem() abort
	if ! exists('b:rcs_id') || ! exists('b:rcs_filename')
		return 0
	endif

	let lnum     = 1
	while match(getline(lnum), '^+++ .\+ +++$') >= 0
		let lnum = lnum + 1
	endwhile

	if match(getline(lnum), '^$') >= 0
		let lnum = lnum + 1
	endif

	let fullrlog = join(getline(lnum, '$'), "\n")

	if fullrlog =~ '^[[:return:][:space:]]*$'
		let fullrlog = '*** empty log message ***'
	endif

	let fullrlog = rcs#shell_escape(fullrlog)
	if v:version >= 702
		let fullrlog = substitute(fullrlog, '\\'."\n", "\n", 'g')
	endif

	let rcs_cmd =  b:sudo . 'rcs -m' . b:rcs_id  . ':' . fullrlog . ' ' . rcs#shell_escape(b:rcs_filename)
	let RCS_Out = system(rcs_cmd)
	if v:shell_error 
            call rcs#print_error(rcs_cmd, RCS_Out) 
        endif

	setlocal nomodified
endfunction

function! s:WinLocalVars(var) abort
	let vals = []
	for i in range(1, tabpagenr('$'))
		for j in range(1, tabpagewinnr(i, '$'))
			let tmp = gettabwinvar(i, j, a:var)
			if tmp != 0 && tmp != ''
				call add(vals, [i, j, tmp])
			endif
		endfor
	endfor
	return vals
endfunction

" }}}1

let &cpoptions = s:savecpo
unlet s:savecpo
