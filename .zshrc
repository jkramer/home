
# ~/.zshrc, written 2005-2009 by Jonas Kramer.

# Clear screen on exit.
trap "/usr/bin/clear" EXIT

# Locale setup.
export LANG="C"
export LC_CTYPE="de_DE.utf8"

# Open screen session if we're in a X terminal and there aren't any sessions
# yet.
SCREENS="`screen -list | grep -ic 'attached'`"
if [[ -z "$STY" && $TERM == *"rxvt"* && "$SCREENS" -eq 0 ]]; then
	export TERM="rxvt"
	/usr/bin/screen -R
	exit
fi
# ---

if [[ $TTY == *"/pts/"* ]]; then
	export TERM='rxvt-unicode'
fi

if [[ ! -z $STY ]]; then
	export TERM='screen-bce'
fi

# Setup $PATH.
typeset -U PATH

export PATH="$HOME/scripts:$PATH:/usr/local/bin:$HOME/.cabal/bin"
# ---


# Colorful prompt.
if [ $TERM = 'screen-bce' -o $TERM = 'screen.rxvt' -o $TERM = 'rxvt-unicode' ]; then
	# 256 color prompt when GNU Screen supports it.
	export PROMPT=$'%{\e[38;5;190m%}[%{\e[38;5;241m%}%n/%m:%(3c,.../%c,%~)%{\e[38;5;190m%}]#%b '
else
	export PROMPT=$'%{\e[1;32m%}[%{\e[1;30m%}%n/%m:%(3c,.../%c,%~)%{\e[1;32m%}]#%b '
fi
# ---


# Less setup.
export PAGER='/usr/bin/less'
export LESS="-rwJQ"

# Vim as default editor.
export EDITOR='/usr/bin/vim'
export VISUAL="$EDITOR"


# Completion setup.
autoload -U zutil
autoload -U compinit
autoload -U complist
compinit

# Extended globbing for fun profit.
setopt extendedglob autocd

# Fix backspace if this is a X11 terminal.
[[ $TERM == 'rxvt' ]] && stty erase '^?'

# Always set X11 display.
export DISPLAY=":0.0"


# History setup.
setopt appendhistory bang_hist extendedhistory 
setopt histignorealldups histfindnodups histreduceblanks

export HISTFILE="$HOME/.zsh/history"
export HISTSIZE=65535
export SAVEHIST=65535

# Load additional functions.
source "$HOME/.zsh/aliases"
source "$HOME/.zsh/keys"

for SCRIPT in $HOME/.zsh/func/*; source "$SCRIPT"
# ---


# CTRL+p pastes the content of the X11 clipboard.
function paste-xclip; {
	BUFFER=$BUFFER"`xclip -o`"
	zle end-of-line
}
zle -N paste-xclip
bindkey "^P" paste-xclip

# CTRL+r searches history.
function search-backwords; {
	zle history-incremental-search-backward $BUFFER
}
zle -N search-backwords
bindkey "^R" search-backwords

# RST colors.
export RST_COLOR_FILENAME='38;5;202'
export RST_COLOR_MATCH='38;5;112'

# Vim template directory.
export VIMTEMPLATE="$HOME/.vim/templates"

stty stop '^°'

[[ -z $BASE ]] && export BASE=$HOME


# Fuck, I hate Java!
export PATH=$PATH:/usr/lib/java/bin
export JAVA_HOME="/usr/lib/java/"
export CLASSPATH=.:/usr/lib/java/:$HOME/source/blackberry/resources/foo
