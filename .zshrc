
# ~/.zshrc, written 2005-2009 by Jonas Kramer.

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

# Terminal setup (required for 256 colors).
if [[ $TERM != "linux" ]]; then
	if [[ $TTY == *"/pts/"* ]]; then
		export TERM='rxvt-unicode'
	fi

	if [[ ! -z $STY ]]; then
		export TERM='screen-bce'
	fi
fi

# Setup $PATH.
typeset -U PATH

export PATH="$HOME/scripts:$HOME/.cabal/bin:$PATH:$HOME/.local/bin"
# ---


# 256-color prompt.
if [ $TERM = 'screen-bce' -o $TERM = 'screen.rxvt' -o $TERM = 'rxvt-unicode' ]; then
	export PROMPT=$'%{\e[38;5;241m%}[%{\e[38;5;238m%}%n/%m:%(3c,.../%c,%~)%{\e[38;5;241m%}]%b# '
else
	export PROMPT=$'%{\e[1;32m%}[%{\e[1;30m%}%n/%m:%(3c,.../%c,%~)%{\e[1;32m%}]#%b '
fi
# ---


# Less setup.
export PAGER='/usr/bin/less'
export LESS="-rwJQiS"

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

for SCRIPT in $HOME/.zsh/func/**/*(.); source "$SCRIPT"
# ---

# RST colors.
export RST_COLOR_FILENAME='38;5;202'
export RST_COLOR_MATCH='38;5;112'

stty stop '^°'

[[ -z $BASE ]] && export BASE=$HOME

autoload -U select-word-style
select-word-style bash
