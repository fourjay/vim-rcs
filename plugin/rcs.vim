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
" $Id: rcs.vim,v 1.50 2010/05/16 22:05:12 infynity Exp $
"
" ChangeLog: {{{1
"
" $Log: rcs.vim,v $
" Revision 1.50  2010/05/16 22:05:12  infynity
" Update URL
"
" Revision 1.49  2010/05/15 20:19:04  infynity
" Make :RCSco check for invalid arguments
"
" Revision 1.48  2010/04/27 19:49:54  infynity
" Wasn't actually running the command to force a check out in the event that
"  the user answered "Yes" to the locked by another user prompt.
"
" Revision 1.47  2010/04/27 03:37:35  infynity
" - Redirect rcsdiff output for checking for unlocked changes to /dev/null
"   (Jon Peatfield)
" - Add a check for a lock by another user in the s:CheckOut() routine
"
" Revision 1.46  2010/04/24 21:18:49  infynity
" Prompt the user on checkout if there were "unlocked" changes, suggested
"  by Jon Peatfield
"
" Revision 1.45  2010/04/24 20:17:25  infynity
" Update version and date
"
" Revision 1.44  2010/04/24 20:14:21  infynity
" Detect RCS's ,v files in the file's cwd as well (Jon Peatfield)
"
" Revision 1.43  2009/06/23 14:05:51  infynity
" Update email address
"
" Revision 1.42  2008/08/09 23:44:23  infynity
" *** empty log message ***
"
" Revision 1.41  2008/08/09 23:38:46  infynity
" Try yet another method of creating/updating the help file
"
" Revision 1.40  2008/08/04 07:36:16  infynity
" - Prompt the user when the file is unwritten and :RCSci is used (Sven Bischof)
" - Sometimes the help file wasn't being generated--try a different method
"   (Sven Bischof)
"
" Revision 1.39  2008/07/11 16:23:15  infynity
" Fix error when g:rcs_plugin_* isn't set (Sven Bischof)
"
" Revision 1.38  2008/06/15 05:46:46  infynity
" Try to safely escape shell commands
"
" Revision 1.37  2008/06/02 07:11:09  infynity
" *** empty log message ***
"
" Revision 1.36  2008/06/01 08:33:45  infynity
" Check all windows in all tabs for the 'diff' option
"
" Revision 1.35  2008/06/01 03:30:08  infynity
" Wasn't checking for the 'diff' option properly.
"
" Revision 1.34  2008/05/31 02:49:48  infynity
" - Allow diffing of two consecutive revisions from the log view
" - Allow folding of the log view
" - Tweaks
"
" Revision 1.33  2008/05/28 20:36:14  infynity
" *** empty log message ***
"
" Revision 1.32  2008/05/27 13:03:33  infynity
" Make entering the log message a little easier
"
" Revision 1.31  2008/05/04 11:10:09  infynity
" Use matchadd() instead of :2match -- less likelyhood of a "collision" with
"   another plugin
"
" Revision 1.30  2008/04/29 20:36:49  infynity
" :RCSUpdateHelp {arg} wasn't working
"
" Revision 1.29  2008/04/26 19:47:08  infynity
" Added the :RCSUpdateHelp [directory] command
"
" Revision 1.28  2008/04/17 06:11:32  infynity
" Delay the helpfile auto-update until Vim has initialized so it won't stop gvim
"  from starting from a non-terminal
"
" Revision 1.27  2008/04/16 03:54:31  infynity
" Enhanced the log display and editing feature
" Auto-install a help file if possible
" Refactoring
"
" Revision 1.26  2008/04/15 04:58:53  infynity
" *** empty log message ***
"
" Revision 1.25  2008/04/15 04:55:38  infynity
" Allow editing of individual revision log messages from the log display
"
" Revision 1.24  2008/04/08 16:28:31  infynity
" *** empty log message ***
"
" Revision 1.23  2008/04/08 16:19:43  infynity
" Internal documentation added
" Code clean up
"
" Revision 1.22  2007/08/08 04:16:45  infynity
" FIleChangedRO autocmd opens folds -- possibly undesirable
"
" Revision 1.21  2006/08/23 04:05:17  infynity
" Perserve cursor position when reloading the buffer after calling co/ci.
"
" Revision 1.20  2006/08/14 07:02:17  infynity
" Changed for Vim7 compatibility.
"
" Revision 1.19  2004/04/17 01:52:18  infynity
" Added copyright information.
"
" Revision 1.18  2004/03/22 12:43:24  infynity
" Fixed detection of existence of diff window for RCS_Diff().
"
" Revision 1.17  2004/01/26 22:31:28  infynity
" Restore 'foldcolumn' when the diff window is closed.
"
" Revision 1.16  2003/12/28 15:05:12  infynity
" Functionalize more stuff.
" Diffing now handled better, including restoring options when the diff window
"  is closed
"
" Revision 1.15  2003/12/20 06:11:26  infynity
" Use "setlocal" rather than "set" in some places.
" Close all folds in both windows when doing a diff view
"
" Revision 1.14  2003/10/09 21:36:05  infynity
" Properly escape $ characters.
"
" Revision 1.13  2003/05/23 21:26:48  infynity
" Change RCSco command call of RCS_CheckOut to use <f-args> rather than <args>.
"
" Revision 1.12  2003/04/21 22:21:12  infynity
" *** empty log message ***
"
" Revision 1.11  2003/04/14 00:24:57  infynity
" *** empty log message ***
"
" Revision 1.10  2003/04/13 03:08:30  infynity
" Syntax highlight the contents of the RCS log window.
"
" Revision 1.9  2003/04/13 01:13:50  infynity
" *** empty log message ***
"
" Revision 1.8  2003/04/12 09:35:56  infynity
" *** empty log message ***
"
" Revision 1.7  2003/04/12 09:34:43  infynity
" Commands for everything added for console vim.
" Show Log command displays in a vim window.
" Tweaks.
"
" Revision 1.6  2003/04/09 20:58:14  infynity
" *** empty log message ***
"
" Revision 1.5  2003/02/05 09:17:07  infynity
" Deleted old commented code.
"
" Revision 1.4  2002/12/07 00:29:48  infynity
" Set 'cpoptions' to make sure the file sources properly, then restore it.
"
" Revision 1.3  2002/09/06 07:26:26  infynity
" Moved RCS.Diff menu item contents to RCSdiff command.
" Use script-local functions &c.
" Other clean-ups.
"
" Revision 1.2  2002/06/29 14:30:00  infynity
" *** empty log message ***
"
" Revision 1.1  2002/06/29 14:10:03  infynity
" Initial revision
"
" }}}1

if v:version < 700
	echohl ErrorMsg
	echomsg 'Vim 7.0 or greater is needed to run ' . expand('<sfile>:p')
	echohl None
	finish
endif

if ! has('unix')
	echohl ErrorMsg
	echomsg expand('<sfile>:p') . 'will probably not work correctly on non-Unix systems'
	echohl None
	finish
endif

" Auto-update the help file if necessary and possible:  {{{1
let s:self    = expand('<sfile>')
 " let s:selfdoc = expand('<sfile>:p:h:h') . '/doc/' . expand('<sfile>:p:t:r') . '.txt'
let s:savecpo = &cpoptions
set cpoptions&vim

" Menus: {{{1
if ! exists("g:loaded_rcs_plugin_menu")
	if has('gui_running') || exists('g:rcs_plugin_menu_force')
		let g:loaded_rcs_plugin_menu = 1

		if ! exists('g:rcs_plugin_toplevel_menu')
			let g:rcs_plugin_toplevel_menu = ''
		endif
		if ! exists('g:rcs_plugin_menu_priority')
			let g:rcs_plugin_menu_priority = ''
		endif

		let s:m = g:rcs_plugin_toplevel_menu
		let s:p = g:rcs_plugin_menu_priority

		if s:m != '' && s:m[-1:] != '.'
			let s:m = s:m . '.'
		endif

		if s:p[-1:] != '.'
			let s:p = s:p . '.'
		endif

		" exe 'amenu <silent> ' . s:p . '10 ' . s:m .
		" 	\ '&RCS.Lock                                  :!rcs -l %<CR>'
		" exe 'amenu <silent> ' . s:p . '20 ' . s:m .
		" 	\ '&RCS.UnLock                                :!rcs -u %<CR>'
		exe 'amenu <silent> ' . s:p . '30 ' . s:m .
			\ '&RCS.&Diff<Tab>:RCSdiff                  :RCSdiff<CR>'
		exe 'amenu <silent> ' . s:p . '40 ' . s:m .
			\ '&RCS.Show\ &&\ Edit\ &Log<Tab>:RCSlog    :RCSlog<CR>'
		exe 'amenu <silent> ' . s:p . '60 ' . s:m .
			\ "&RCS.Check\\ Out\\ [&RO]<Tab>:RCSco\\ ro :RCSco ro<CR>"
		exe 'amenu <silent> ' . s:p . '60 ' . s:m .
			\ "&RCS.Check\\ Out\\ [&W]<Tab>:RCSco\\ w   :RCSco w<CR>"
		exe 'amenu <silent> ' . s:p . '70 ' . s:m .
			\ '&RCS.Check\ &In<Tab>:RCSci               :RCSci<CR>'

		unlet s:m s:p
	else
		augroup RCS_plugin_menu
			au!
			exe 'autocmd GUIEnter * source ' . expand('<sfile>')
		augroup END
	endif
endif
" }}}1

if exists("g:loaded_rcs_plugin")
	let &cpoptions = s:savecpo
	unlet s:savecpo
	finish
endif
let g:loaded_rcs_plugin = 1

let b:sudo = ""
if exists("g:sudo_rcs_plugin")
    let b:sudo = "sudo "
endif

" Autocommands: {{{1
augroup RCS_plugin
	au!
	autocmd BufUnload * nested call s:BufUnload()
augroup END

" Commands: {{{1
command!          RCSdiff call s:Diff(expand("%:p"))
command!          RCSlog  call s:ViewLog(expand("%:p"))
command! -complete=custom,<SID>rcscomplete -nargs=? RCSco   call s:CheckOut(expand("%:p"), <f-args>)
command! -nargs=? RCSci   call s:CheckIn(expand("%:p"))
function! s:rcscomplete(...)
    return "w\nro\n"
endfunction

command! RCSsudo let b:sudo="sudo "
command! RCSwork call s:CheckIn(expand("%:p"), "lock" )

command! RCSnostrict :call system( b:sudo . " rcs -U " . expand("%s:p") )

" Functions: {{{1

function! s:FileChangedRO()  " {{{2
	if (filereadable(expand('<afile>:p:h') . '/RCS/' . expand("<afile>:t") . ',v')
				\ || filereadable(expand('<afile>') . ',v'))
				\ && (confirm("This is a read-only RCS controlled file, check out?", "&Yes\n&No", 1, "Q") == 1)
		call s:CheckOut(expand('<afile>:p'), 1)
		silent! foldopen!
	endif
endfunction

function! s:BufUnload()  " {{{2
	if getbufvar(expand('<afile>:p'), 'RCS_CheckedOut') != ''
				\ && (getbufvar(expand('<afile>:p'), 'RCS_CheckedOut') == expand('<afile>:p'))
				\ && (confirm(expand('<afile>:t') . " is an RCS controlled file checked out by Vim.\nCheck back in?", "&Yes\n&No", 1, "Q") == 1)
		call s:CheckIn(expand('<afile>:p'), 0)
	endif
endfunction

function! s:Diff(file)  " {{{2
	if len(s:WinLocalVars('&diff')) > 0
		echohl ErrorMsg
		echomsg "It appears Vim is already running a diff, close those buffers first."
		echohl None
		return 0
	endif

	let rcs_diff_name = "[Previous version of " . fnamemodify(a:file, ':t') . "]"

	if bufnr('^\V' . rcs_diff_name) != -1
		echohl ErrorMsg
		echo "Already viewing differences for the current file."
		echohl None
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

	silent call system( b:sudo . 'co -p ' . s:ShellEscape(a:file) . ' > ' . s:ShellEscape(rcs_diff_file) . ' 2> /dev/null')
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

	normal zX
	wincmd p
	normal zX
endfunction

function! s:CheckForLock(file) " {{{2
	let rlog_out = split(system('rlog -L -h ' . a:file), '\n')
	if len(rlog_out) == 0
		return ''
	endif

	let locker = ''
	let index = 0
	while index < len(rlog_out)
		if rlog_out[index] =~? '\slocked by: \S\+;'
			let locker = substitute(rlog_out[index], '.*\slocked by: \(\S\+\);.*', '\1', '')
			break
		endif
		let index = index + 1
	endwhile

	return locker
endfunction

function! s:CheckOut(file, ...)  " {{{2
	let mode = ''

        if a:0 == 0
            let a:mode = 'w'
        endif
	if a:mode == 1 || a:mode ==? 'w'
		let mode = '-l '
	elseif a:mode != '0' && a:mode !=? 'ro' && a:mode !=? 'r'
		echohl ErrorMsg
		echo 'Unknown argument: ' . a:mode . '  Valid arguments are "r"/"ro" or "w".'
		echohl None
		return
	endif

	let locker = s:CheckForLock(a:file)

	if locker != '' && locker != $LOGNAME . 'a'
		let confirm_promt =                 a:file . " appears to have been locked by username '" . locker . "'.\n"
                let confirm_promt = confirm_promt . "Force a check out anyway (this could cause loss of data)?"
		if confirm(confirm_promt, "&Yes\n&No", 2, 'W') == 2
			return
		else
			let mode = '-f ' . mode
			let RCS_Out = system(b:sudo . 'co ' . mode . s:ShellEscape(a:file))
		endif
	elseif filewritable(a:file)
		if confirm(a:file . " is writable (locked).\nForce a check out of previous version (your changes will be lost)?", "&Yes\n&No", 2, 'W') == 1
			let mode = '-f ' . mode
			let RCS_Out = system(b:sudo . 'co ' . mode . s:ShellEscape(a:file))
		elseif a:mode == 1 || a:mode == 'w' && confirm('Tell Vim this is a controlled RCS file anyway?', "&Yes\n&No", 1, 'Q') == 1
			let b:RCS_CheckedOut = a:file
			return
		else
			return
		endif
	else
		silent! exe '!rcsdiff ' . s:ShellEscape(a:file) . ' >/dev/null 2>&1'
		if v:shell_error > 0 && confirm(a:file . " appears to have been modified without being checked out writable (locked) first.\nCheck out anyway (changes, if any, will be lost)?", "&Yes\n&No", 2, 'W') == 2
			return

		else
			let co_cmd = b:sudo . 'co ' . mode . s:ShellEscape(a:file)
			let RCS_Out = system(co_cmd)
		endif
	endif

	if v:shell_error
		call s:print_error( co_cmd, RCS_Out)
		return 1
	endif

	if a:mode == 1 || a:mode == 'w'
		let b:RCS_CheckedOut = a:file
	elseif exists('b:RCS_CheckedOut')
		let b:RCS_CheckedOut = ''
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

function! s:CheckIn(file, ...)  " {{{2
	if (getbufvar(a:file, '&modified') == 1)
				\ && (confirm(fnamemodify(a:file, ':t') . " has unwritten changes, check in anyway?", "&Yes\n&No", 2, "Q") != 1)
		return
	endif

        let lock_flag = ''
        if a:0 > 0
            let lock_flag = " -l "
        endif

	call setbufvar(a:file, 'RCS_CheckedOut', '')

	let message=printf('%-70s', 'Enter log message for "' . fnamemodify(a:file, ':t') . '" (. to end):')

	if strlen(message) <= 70
		if &columns >= 80
			echo message . "<-70 80->|\n"
		else
			echo message . "<-70\n"
		endif
	endif

	let rlog = "" | let fullrlog = ""

	while rlog != "."
		let fullrlog = fullrlog . "\n" . rlog
		let rlog = input("> ")
		echo "  " . rlog . "\n"
	endwhile

	if fullrlog =~ '^[[:return:][:space:]]*$'
		let fullrlog = '*** empty log message ***'
	endif

	let fullrlog = s:ShellEscape(fullrlog)
	if v:version >= 702
		let fullrlog = substitute(fullrlog, '\\'."\n", "\n", 'g')
	endif

        let ci_cmd = b:sudo . " ci -f " . lock_flag . " -m" . fullrlog  . " " . s:ShellEscape(a:file)
	let RCS_Out = system( ci_cmd )
        if v:shell_error
            call s:print_error( ci_cmd, RCS_Out )
        else
            if exists( '#User#RCSciEvent' )
                doautocmd User RCSciEvent
            endif
        endif

        if lock_flag == ''
            let co_cmd = b:sudo . 'co -u ' . s:ShellEscape(a:file)
            let RCS_Out = system(co_cmd)
            if v:shell_error 
                call s:print_error( co_cmd, RCS_Out ) 
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

function! s:ViewLog(file)  " {{{2
	let file_escaped=escape(fnamemodify(a:file, ':t'), ' \')

        " store b:sudo for new window
        let l:do_sudo = b:sudo
	exe 'silent topleft new [RCS\ log\ for\ ' . file_escaped . ']'
	let b:rcs_filename = a:file
        " re-register b:sudo
        let b:sudo = l:do_sudo

	call s:ViewLog2(a:file)

	syntax case match
	syntax match rcslogDelim  '^-\{4,}$'
	syntax match rcslogDelim  '^=\{4,}+$'
	syntax match rcslogValues '^revision [0-9.]\+$' contains=rcslogNumber
	syntax match rcslogFile   '^\(RCS file\|Working file\): .\+' contains=rcslogString
	syntax match rcslogValues '^\(head\|branch\|locks\|access list\|symbolic names\|keyword substitution\|total revisions\|description\|locked by\|date\):\( [^;]\+\)\=' contains=rcslogString
	syntax match rcslogValues '\(author\|state\): [^;]\+;'me=e-1 contains=rcslogString
	syntax match rcslogValues '\(lines\|selected revisions\): [ 0-9+-]\+$' contains=rcslogNumber
	syntax match rcslogString ': [^;]\+'ms=s+2 contained contains=rcslogNumber
	syntax match rcslogNumber '[+-]\=[0-9.]\+' contained
	highlight default link rcslogKeys    Comment
	highlight default link rcslogDelim   PreProc
	highlight default link rcslogValues  Identifier
	highlight default link rcslogFile    Type
	highlight default link rcslogString  String
	highlight default link rcslogNumber  Number
	highlight default link rcslogCurrent NonText

	setlocal buftype=nofile noswapfile readonly nomodifiable bufhidden=wipe
	setlocal foldexpr=RCSFoldLog() foldmethod=expr

	normal zR

	nnoremap <buffer> <nowait> q <C-w>c
	nnoremap <buffer> <space> <C-f>
	nnoremap <buffer> b <C-b>
	nnoremap <silent> <buffer> J :if search('^-\+\nrevision \d\+\.\d\+', 'W')<bar>exe 'normal j'<bar>endif<CR>
	nnoremap <silent> <buffer> K :call search('^revision \d\+\.\d\+', 'Wb')<CR>
				\:call search('^-\+\nrevision \d\+\.\d\+', 'Wb')<CR>j
	nnoremap <silent> <buffer> <cr> :call <SID>EditLogItem()<CR>
	nnoremap <silent> <buffer> d :call <SID>LogDiff()<CR>
	nnoremap <silent> <buffer> <c-l> <c-l>:call <SID>ViewLog2(b:rcs_filename)<CR>

	autocmd CursorMoved <buffer> call s:LogHighlight()
endfunction

function! s:ViewLog2(file)  " {{{2
	setlocal noreadonly modifiable
	let where = s:ByteOffset()
	silent! 1,$delete
	exe 'silent 0r !rlog ' . s:ShellEscape(a:file)
	let keys = [
			\ '+++ Keys:                                                            +++',
			\ '+++  <space>     -  Page down                                        +++',
			\ '+++  b           -  Page up                                          +++',
			\ '+++  <control-l> -  Refresh the screen and reload the log            +++',
			\ '+++  J           -  Jump to next log section                         +++',
			\ '+++  K           -  Jump to previous log section                     +++',
			\ "+++  <enter>     -  Edit the current revision entry's message        +++",
			\ "+++  d           -  Diff the current revision with the previous one  +++",
			\ '+++  q           -  Close this log view                              +++',
		\ ]
	call append(0, keys)
	setlocal readonly nomodifiable
	1 " Go to the first line in the file.
	silent! execute 'goto ' . where

	exe 'syntax match rcslogKeys   =^\%<' . (len(keys) + 1) . 'l+++ .\+ +++$='
endfunction

function! RCSFoldLog()  " {{{2
	if getline(v:lnum) =~ '^+++ .\+ +++$'
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

function! s:LogHighlight()  " {{{2
	let curline = line('.')
	let idarr = s:GetLogId(curline)

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

function! s:GetLogId(line)  " {{{2
	let offset = s:ByteOffset()
	call cursor(a:line, 0)

	let back    = search('^-\+\nrevision \d\+\.\d\+', 'bWn')
	let forward = search('^-\+$', 'Wn')

	exe 'go ' . offset

	if back > 0 && a:line >= back && a:line <= forward && getline('.') !~ '^-\+$'
		let line = getline(back + 1)
		let id   = substitute(line, 'revision \(\d\+\.\d\+\).*', '\1', '')

		return [id, back, forward]
	else
		return [-1, -1, -1]
	endif
endfunction

function! s:LogDiff()  " {{{2
	if ! exists('b:rcs_filename')
		echohl ErrorMsg
		echomsg "Can't determine the filename associated with the current log"
		echohl None
		return 0
	endif

	if len(s:WinLocalVars('&diff')) > 0
		echohl ErrorMsg
		echomsg "It appears Vim is already running a diff, close those buffers first."
		echohl None
		return 0
	endif

	let rcs_filename = b:rcs_filename

	let curline = line('.')
	let idarr1 = s:GetLogId(curline)

	if idarr1[0] != -1
		let idarr2 = s:GetLogId(idarr1[2] + 1)
	endif

	if idarr1[0] == -1 || idarr2[0] == -1
		echohl ErrorMsg
		echomsg "Can't determine the revision IDs to diff"
		echohl None
		return 0
	endif

	let file_escaped=escape(fnamemodify(rcs_filename, ':t'), ' \')

	exe 'silent topleft new [' . file_escaped . ', revision ' . idarr2[0] . ']'
	silent exe 'read !co -p -r' . idarr2[0] . ' ' . s:ShellEscape(rcs_filename) . ' 2>/dev/null'
	diffthis
	setlocal buftype=nofile noswapfile readonly nomodifiable bufhidden=wipe
        nnoremap <buffer> <nowait> q :bwipe<Cr>
         " nnoremap <buffer> <nowait> j :wincmd j<cr> | :wincmd j

	exe 'silent vertical rightbelow new [' . file_escaped . ', revision ' . idarr1[0] . ']'
	silent exe 'read !co -p -r' . idarr1[0] . ' ' . s:ShellEscape(rcs_filename) . ' 2>/dev/null'
	diffthis
	setlocal buftype=nofile noswapfile readonly nomodifiable bufhidden=wipe
        nnoremap <buffer> <nowait> q :bwipe<Cr>
        nnoremap <buffer> <nowait> j :wincmd j<cr>

	wincmd p
        nnoremap <buffer> <nowait> q :wincmd l<cr>:bwipe<cr>:bwipe<cr>
	wincmd _
	1
endfunction

function! s:EditLogItem()  " {{{2
	if ! exists('b:rcs_filename')
		echohl ErrorMsg
		echomsg "Can't determine the filename associated with the current log"
		echohl None
		return 0
	endif

	let rcs_filename = b:rcs_filename

        " add support for sudo grab buffer variable for later
        " re-registration
        let do_sudo = b:sudo

	let curline = line('.')
	let idarr = s:GetLogId(curline)

	if idarr[0] != -1
		let fname =  '[Log entry for ' . fnamemodify(rcs_filename, ':p:t') . ' revision ' . idarr[0] . ']'

		if bufloaded(fname)
			echohl ErrorMsg
			echo "A buffer for that log message already exists"
			echohl None
			return 0
		endif

		execute 'new ' . escape(fname, ' \')
		setlocal buftype=acwrite bufhidden=wipe
		let b:rcs_id       = idarr[0]
		let b:rcs_filename = rcs_filename
                " re-register b:sudo flag for edit window
                let b:sudo = do_sudo
		silent! execute 'read !rlog -r' . idarr[0] . ' ' . s:ShellEscape(rcs_filename)
		silent! 1,/^revision .\+\ndate: \d\{4\}\/\d\d\/\d\d \d\d:\d\d:\d\d.*/+1 delete
		silent! $delete
		call append(0, ["+++ Change the log message below this line and write+quit +++", ''])
		setlocal nomodified

		syntax match rcslogKeys =^\%<2l+++ .\+ +++$=
		highlight default link rcslogKeys Todo

		autocmd BufWriteCmd <buffer> call s:SaveLogItem()
	else
		echohl ErrorMsg
		echom "The cursor isn't within a log section"
		echohl None
		return 0
	endif
endfunction

function! s:SaveLogItem()  " {{{2
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

	let fullrlog = s:ShellEscape(fullrlog)
	if v:version >= 702
		let fullrlog = substitute(fullrlog, '\\'."\n", "\n", 'g')
	endif

	let rcs_cmd =  b:sudo . "rcs -m" . b:rcs_id  . ":" . fullrlog . " " . s:ShellEscape(b:rcs_filename)
	let RCS_Out = system(rcs_cmd)
	if v:shell_error 
            call s:print_error(rcs_cmd, RCS_Out) 
        endif

	setlocal nomodified
endfunction

function! s:ByteOffset()  " {{{2
	let offset = line2byte(line(".")) + col(".") - 1
	return (offset < 1 ? 1 : offset)
endfunction

function! s:WinLocalVars(var)  " {{{2
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

function! s:UpdateHelp(self, doc)  " {{{2
        return
	let docdir = fnamemodify(a:doc, ':p:h')

	if ! isdirectory(docdir)
		call mkdir(docdir, 'p')
	endif

	if filewritable(docdir) != 2
		echohl ErrorMsg
		echomsg "Can't write to directory \"" . docdir . "\"." . 
					\"  Please make sure it exists as a directory and is writable."
		echohl None
		return 0
	endif

	echomsg "Updating help file for " . fnamemodify(a:self, ':p:t')

	let lines = readfile(a:self)

	if len(lines) <= 0
		echohl ErrorMsg
		echomsg "Unable to scan \"" . a:self . "\" for help file."
		echohl None
		return 0
	endif

	for i in range(len(lines))
		if lines[i] =~ '^" Last Change:'
			let lastchange = substitute(lines[i], '" ', '\t\t', '')
		elseif lines[i] =~ '^finish " -- Help file follows: {\{3}$'
			let starthelp = i + 2
			break
		endif
	endfor

	call insert(lines, lastchange, starthelp + 1)
	call writefile(lines[starthelp :], a:doc)

	silent execute 'helptags ' . docdir

	return 1
endfunction

function! s:print_error(cmd, error)
    echohl ErrorMsg
    echo "Nonzero exit status from: " . a:cmd
    echo a:error
    echohl None
    let v:errmsg = a:error
endfunction

function! s:ShellEscape(str) " {{{2
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
" }}}1

let &cpoptions = s:savecpo
unlet s:savecpo
