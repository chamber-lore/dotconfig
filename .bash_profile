#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# extra globbing, nulls globbed as empty, ** globs dirs, rows and cols updated after each command
shopt -s extglob
shopt -s nullglob
shopt -s globstar
shopt -s checkwinsize

# history
HISTSIZE=2000
HISTCONTROL=ignorespace
HISTFILE=$HOME/.bash_history

# env
export PATH=$HOME/bin:$PATH
export EDITOR=/usr/bin/nvim
export WINEPREFIX=$HOME/.wine

# homedir cleanup (one-line commentable)

find . -maxdepth 1 -type d -name '[A-Z]*' -exec rmdir --ignore-fail-on-non-empty -v {} \;
histdel () {
	find . -maxdepth 1 -type f \( -name '.*_history' -o -name '*hst*' \) -print0 | while read -rd $'\0' histfile; do
		case "$histfile" in
			# could check against *'.bash_history'* instead but it feels better to be exact
			'./.bash_history');;
			*) mv -v "$histfile" /tmp;;
		esac
	done
}
histdel
rm nohup.out 2>/dev/null
