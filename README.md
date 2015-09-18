Forked from http://www.vim.org/scripts/script.php?script_id=1111

This is a wrapper around RCS.

RCS is still a fairly decent way to add one-off ad-hoc version control
particularly for system administration work. The original  plugin 
works well, but has some issues in this scenario.

* The plugin prompts for checkout too aggressively. I commonly use my
  user account to open root owned files. The plugin sees the lock
  condition and prompts for (an uncompletable) checkout.

* I'd like to be able to sudo ci. This mirrors the (various) SudoWrite
  actions.

*Original Commands*
With changes

    RCSco   - The same

    RCSco   - made "w" the default

    RCSDiff - The same

*New Commands*

    RCSSudo - set a per buffer persistant sudo on RCS commands

    RCSwork - A common workflow, ci, then co -l.
    This streamlines a common workflow
