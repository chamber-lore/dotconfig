#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# util
alias ls='ls --color=auto'
alias lf='ls -Alh'
alias lc='ls -CF'
alias grep='grep --color=auto'
alias nv='nvim'
alias vim='nvim'
alias .='pwd'
alias ..='cd ..'
alias ~='cd ~'
# make this better!
alias foldersort='du . -chd 1 | sort -h'
s () {
	if [ "$#" -eq 0 ]; then
		cmd="$(history -p '!!')"
		sudo "$cmd"
	else
		sudo "$@"
	fi
}
extract () {
	r () {
		[ -n "$2" ] && rm "$1"
	}
	if [ -f "$1" ]; then
		case $1 in
			*.tar.bz2)	tar xjf "$1" && r "$@";;
			*.tar.gz)	tar xzf "$1" && r "$@";;
			*.bz2)		bunzip2 "$1" && r "$@";;
			*.rar)		rar x "$1" && r "$@";;
			*.gz)		gunzip "$1" && r "$@";;
			*.tar)		tar xf "$1" && r "$@";;
			*.tbz2)		tar xjf "$1" && r "$@";;
			*.tgz)		tar xzf "$1" && r "$@";;
			*.zip)		unzip "$1" && r "$@";;
			*.Z)		uncompress "$1" && r "$@";;
			*.7z)		7zz x "$1" && r "$@";;
			*)		printf "'%s' cannot be extracted via extract()" "$1"
		esac
	else
		printf "'%s' is not a valid file\n" "$1"
	fi
}
gt () {
	path="$_"
	if ! [ "${path:0:1}" = '/' ]; then
		path="$(realpath "$path" 2>/dev/null)"
	fi
	[ -f "$path" ] && path="$(printf '%s' "$path" | sed 's/^\(.*\)\/[^\/]*$/\1/')"
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
# this could be universalized like fm, but atm that doesn't seem worth it (the cost of typing out the full path vs. the lack of other sizeable groups of numbered files on my system)
vnc () {
	which='anti'
	[ -n "$1" ] && which="$1"
	num="$(find ~/auds/miyu -maxdepth 1 -type f | sed "s/^.*for.*$which\([0-9]*\)\..*$/\1/" | sort -n | tail -n1)"
	printf '%b' "Current: $num, next: $((num+1))\n"
}
alias Internet='sudo Internet'

PS1='[\u@\h \W]\$ '
