#
# ~/.bash_profile
#

# shellcheck shell=bash
# shellcheck disable=SC1090,SC3010,SC3044

# clear alias list
unalias -a

[[ -f ~/.bashrc ]] && . ~/.bashrc

# extra globbing, nulls globbed as empty, ** globs dirs, rows and cols updated after each command
shopt -s extglob
shopt -s nullglob
shopt -s globstar
shopt -s checkwinsize

# history
export HISTSIZE=2000
export HISTCONTROL=ignorespace
export HISTFILE="$HOME"/.bash_history

# env
export PATH="$HOME"/bin:"$HOME"/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl
export EDITOR=/usr/bin/nvim
export WINEPREFIX="$HOME"/.wine

# homedir cleanup (one-line commentable)
find . -maxdepth 1 -type d -name '[A-Z]*' -exec rmdir --ignore-fail-on-non-empty -v {} \;
histdel () {
	find . -maxdepth 1 -type f \( -name '.*_history' -o -name '*hst*' \) -print0 | while read -rd $'\0' histfile; do
		case "$histfile" in
			# could check against *'.bash_history'* instead but it feels better to be exact
			'./.bash_history');;
			*) mv -v "$histfile" /tmp
		esac
	done
}
histdel
dotconfig () {
  files=("$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/bin/convxlog" "$HOME/bin/dlxfile" "$HOME/bin/food" "$HOME/bin/Internet" "$HOME/bin/keepawake" "$HOME/bin/playvid" "$HOME/bin/wakeup" "$HOME/.config/bspwm/bspwmrc" "$HOME/.config/lemonbar/lemonbarrc" "$HOME/.muttrc" "$HOME/.mutt/danwin" "$HOME/.mutt/disroot" "$HOME/.mutt/paranoid" "$HOME/.mutt/purgecache.sh" "$HOME/.config/picom/picom.conf" "$HOME/.config/profanity/profrc" "$HOME/.config/qutebrowser/config.py" "$HOME/.config/qutebrowser/jmatrix-rules" "$HOME/.config/sxhkd/sxhkdrc" "$HOME/.mozilla/firefox/m9njnno4.arkenfox/user.js" "$HOME/.vimrc")
  for file in "${files[@]}"; do
    case "$file" in
      *"$HOME/bin/"*) cp -v "$file" ~/git/dotconfig/bin;;
      *"$HOME/.mutt/"*) cp -v "$file" ~/git/dotconfig/neomutt;;
      *"$HOME/.config/qutebrowser/"*) cp -v "$file" ~/git/dotconfig/qutebrowser;;
      *) cp -v "$file" ~/git/dotconfig
    esac
  done
}
dotconfig
rm nohup.out 2>/dev/null
