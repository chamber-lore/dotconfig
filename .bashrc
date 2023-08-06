#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# setup
shopt -s extglob # extra globbing
shopt -s nullglob # nulls are globbed as empty strings
shopt -s checkwinsize # updates rows and cols after each command

# env
export PATH="$HOME/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"
export WINEPREFIX="$HOME/.wine"

# personal
[ -d "$HOME/Downloads" ] && rmdir "$HOME/Downloads"
HISTCONTROL=ignorespace

# util
alias ls='ls --color=auto'
alias lf='ls -Alh'
alias lc='ls -CF'
alias grep='grep --color=auto'
alias .='pwd'
alias ..='cd ..'
alias ~='cd ~'
# make this better!
alias foldersort='du . -chd 1 | sort -h'
s () {
	if [ "$#" -eq 0 ]; then
		sudo "$(history -p '!!')"
	else
		sudo "$@"
	fi
}
extract () {
     if [ -f "$1" ]; then
         case $1 in
             *.tar.bz2)   tar xjf "$1"        ;;
             *.tar.gz)    tar xzf "$1"     ;;
             *.bz2)       bunzip2 "$1"       ;;
             *.rar)       rar x "$1"     ;;
             *.gz)        gunzip "$1"     ;;
             *.tar)       tar xf "$1"        ;;
             *.tbz2)      tar xjf "$1"      ;;
             *.tgz)       tar xzf "$1"       ;;
             *.zip)       unzip "$1"     ;;
             *.Z)         uncompress "$1"  ;;
             *.7z)        7zz x "$1"    ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}
gt () {
	path="$(printf '%s' "$_" | sed "s|~|$HOME|")"
	if ! [ "${path:0:1}" = '/' ]; then
		# could do something more sophisticated and check if the latest cd was for the original path (opath, which is just $_)
		if [ "$(history | tail -n2 | head -n1 | awk '{print $2}')" = 'cd' ]; then
			path="$OLDPWD/$path"
		else
			path="$PWD/$path"
		fi
	fi
	[ -f "$path" ] && path="$(printf '%s' "$path" | sed 's/^\(.*\)\/[^\/]*$/\1/')"
	path="$(find / 2>/dev/null | grep "$path" | head -n1)"
	if [ -d "$path" ]; then
		printf "Navigating to %s\n" "$path"
		cd "$path" || exit
	else
		printf "Not a directory, sorry\n"
	fi
}

# bin
alias lemonbarrc="pkill lemonbar && ~/.config/lemonbar/lemonbarrc | lemonbar -p -g \$(xwininfo -root | grep 'Width' | cut -c 10-)x40 & disown && \$SHELL"
alias cheese='cheese & disown && exit 0'
alias lynx='lynx -cfg=~/.config/lynx/lynx.cfg'
alias firefox="firefox --new-instance --url 'about:blank' 2>/dev/null & disown && exit 0"
alias qutebrowser='qutebrowser & disown && exit 0'
alias tor="sudo tor 2>/dev/null & disown"
alias onioncircuits='onioncircuits & disown && exit 0'
alias mumble='mumble & disown && exit 0'
alias audacity='audacity & disown && exit 0'
alias obs='obs & disown && exit 0'
alias qbittorrent='qbittorrent & disown && exit 0'
alias keepass='keepassxc ~/docs/antinomicon.kdbx & disown && exit 0'
alias herst='wg-quick up ~/.config/wireguard/her.st/antimetabolism.conf'
alias codium='codium & disown && exit 0'

# my bin
fm () {
	sum=0
	path="$HOME/auds/miyu/for_miyu*"
	[ -n "$1" ] && path="$(printf '%s' "$1" | sed "s|~|$HOME|")"
	for f in $path; do
		cur="$(ffprobe -i "$f" -show_entries format=duration -v quiet -of csv="p=0" 2>/dev/null | awk -F'.' '{print $1}')"
		sum=$((sum+cur))
	done
printf "%s\n" "$(date -d @"$sum" -u +%H:%M:%S)"
}
miyu () {
	printf '%b' "$(cat ~/docs/logs/miyu_out.txt ~/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/miyu_at_witch.crft.sh/* | sed 's/^.*[miyu\@witch\.crft\.sh|miyu|me]: \(.*\)$/\1/')\n"
}
vnc () {
	which='anti'
	[ -n "$1" ] && which="$1"
	num="$(find ~/auds/miyu -maxdepth 1 -type f | sed "s/^.*for.*$which\([0-9]*\)\..*$/\1/" | sort -n | tail -n1)"
	printf '%b' "Current: $num, next: $((num+1))\n"
}
alias Internet='sudo Internet'

PS1='[\u@\h \W]\$ '
