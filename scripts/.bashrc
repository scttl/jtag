################################################################################
##
## FILE: .bashrc 
##
## CVS: $Id: .bashrc,v 1.1 2003-06-04 14:23:18 scottl Exp $
##
## DESCRIPTION: Each non-login shell reads this file upon startup.  Converted
##              the ~.cshrc to a bash-like structure.
##
################################################################################



## COMMAND, LIBRARY AND MANPAGE PATHS ##

# Initial sensible path and manpath
PATH="/bin:/usr/bin:/local/bin:/usr/ucb:/usr/ccs/bin"
MANPATH="/local/man:/usr/man:/usr/share/man"

# X related paths
PATH="$PATH:/local/X11/bin:/usr/bin/X11:/local/bin/X11:/usr/openwin/bin"
MANPATH="$MANPATH:/local/X11/man:/usr/X11R6/man:/usr/openwin/man"

# SUNWspro stuff (not used currently)
# PATH="/local/lib/SUNWspro/bin:$PATH"
# MANPATH="/local/lib/SUNWspro/man:$MANPATH"
# LD_LIBRARY_PATH="/local/lib/SUNWspro/lib:$LD_LIBRARY_PATH"
# export LD_LIBRARY_PATH

# My personal path and manpath
PATH="$HOME/bin:$PATH"
MANPATH="$HOME/man:$MANPATH"

# Export their values to subsequent shells
export PATH
export MANPATH



## UMASK SETTING ##

umask 022



## ENVIRONMENT VARIABLES ##

# Editor and Pager settings
export EDITOR=vi
export VISUAL=vi
export PAGER=less
export LESS="MeQd"

# The file /etc/printcap lists available printers.
# Here's how to change the default printer:
#export PRINTER=printername

# To tell TeX to search your private macro library in ~/tex,
# uncomment this.  The trailing colon is shorthand
# for the default TEXINPUTS value.
#export TEXINPUTS=".:$HOME/tex:"

# The file /common/locatedbs/.LOCATE_PATH contains the
# local list of gnulocate databases:
#if ( -r /common/locatedbs/.LOCATE_PATH ) then
#	export LOCATE_PATH=`cat /common/locatedbs/.LOCATE_PATH`
#endif



## ALIASES ##
 
# Use this to scan your backup mailbox
# alias oldmail mail -f /var/oldmail/$USER

# Prevent creation of pine-debug files
alias pine="pine -d 0"
alias vi="vim"



## PROMPT SETTING ##

if [ "$PS1" ]; then
  PS1='[\u@\h: \w]$'
fi

export PS1



## MISCELLANEOUS ##

unset autologout	# No autologout.
#set ignoreeof		# Don't log out on Control-D.

set history  250 notify filec
set mail 300 "/var/mail/$USER"

# If you don't like the default terminal settings,
# use the "stty" command to change them here,
# for example, if you want ^H to backspace and DELETE to interrupt,
# use this:
#stty erase '^H' intr '^?'
