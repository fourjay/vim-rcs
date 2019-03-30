Updated RCS wrapper
===================

Forked from http://www.vim.org/scripts/script.php?script_id=1111

This is a wrapper around RCS. Unlike the original plugin this uses normal vim
editing commands for commit messages. It's also been tweaked for my use cases,
in particular support for privilege escalation through sudo and repeated
edit -> cycles.

RCS is still a fairly decent way to add one-off ad-hoc version control
particularly for system administration work. The original plugin 
works well, but has some issues in this scenario.

* The plugin prompts for checkout too aggressively. I commonly use my
  user account to open root owned files. The plugin sees the lock
  condition and prompts for (an uncompletable) checkout.

* I'd like to be able to sudo ci. This mirrors the (various) SudoWrite
  actions.

The original uses input() to emulate rcs's primitive editor. This seems
a waste, as vim is a superb editor. I've altered the code to use a vim
split.

*Original Commands*
With changes

    RCSco   - The same

    RCSco   - made "w" the default

    RCSDiff - The same

*New Commands*

    RCSSudo - set a per buffer persistant sudo on RCS commands

    RCSwork - A common workflow, ci, then co -l.
    This streamlines a common workflow

    RCSnostrict - enable loose(r) lock behavior ``rcs -U [filename]``

# Other differences

The script has been (partially) updated to more modern vim plugin structure.
The original plugin was written to as a single self contained script and
included a help document unpacking/updating function. Modern runpath
manipulation allows files to be separated out more naturally. Notably, although
it's a work in progress, I've moved code to autoload, a syntax and filetype
folder (for rlog output) and some initial testing which makes the code

* easier to maintain
* easier to test
* load faster

I've removed the menu creation code. I've no problems with such additions, but
also see little benefit to it (from my viewpoint, it'd be easier/quicker to
suspend and enter commands directly than to choose a menu item). Since the
structuring took a fair amount of time on load, I disabled it by default,
adding an option to load.

The maintainer of the original plugin, Christian J. Robinson, has recently
updated the plugin, mostly by always loading the menu code and adding windows
support. I've not looked at the new code, but since I've taken this plugin in a
significantly different direction, I've decided to remove the menuing code. The
divergence is now wide. When I originally put this out on github, I contact the
Mr Robinson, but did not hear from him. At this point the plugin, though based
on the same work, is now significantly different.
