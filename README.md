Forked from http://www.vim.org/scripts/script.php?script_id=1111

RCS is still a fairly decent way to add one-off ad-hoc version control
particularly for system administration work. The original  plugin 
works well, but has some issues in this scenario.

* The plugin prompts for checkout too aggressively. I commonly use my
  user account to open root owned files. The plugin sees the lock
  condition and prompts for (an uncompletable) checkout.

* I'd like to be able to sudo ci. This mirrors the (various) SudoWrite
  actions.

This is a set of autocommands, commands, and a menu to help you handle RCS controlled files.

If you try to modify a readonly file that has a RCS/<file>,v counterpart
you will be asked if you want to check the file out for modification,
and when you unload the buffer you'll be prompted if you want to check
the file back in, and allowed to enter a log message.

Most of the commands have corresponding menu items, which should be fairly self-explanatory.

Details are in the auto-generated help file, see ":help rcs.txt".
