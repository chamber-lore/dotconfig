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
export EDITOR=/usr/bin/vim
export BROWSER=/usr/bin/qutebrowser
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
  files=(".bash_profile" ".bashrc" "bin/convxlog" "bin/dlxfile" "bin/food" "bin/Internet" "bin/keepawake" "bin/playvid" "bin/wakeup" ".config/bspwm/bspwmrc" ".config/lemonbar/lemonbarrc" "docs/logs/get_log.sh" "docs/logs/get_all.sh" "vids/music_download.sh" "vids/music_download_mkv.sh" ".muttrc" ".mutt/danwin" ".mutt/disroot" ".mutt/purgecache.sh" ".config/picom/picom.conf" ".config/profanity/profrc" ".config/qutebrowser/config.py" ".config/qutebrowser/jmatrix-rules" ".config/sxhkd/sxhkdrc" ".mozilla/firefox/8w40cz1t.hardened/user.js" ".vimrc")
  for file in "${files[@]}"; do
    dir=$(dirname "$file")
    [ "$dir" != '.' ] && mkdir -p ~/git/dotconfig/"$(dirname $file)"
    cp -v "$HOME/$file" ~/git/dotconfig/"$file"
  done
}
dotconfig
find / -name 'nohup.out' 2>/dev/null | xargs rm 2>/dev/null
