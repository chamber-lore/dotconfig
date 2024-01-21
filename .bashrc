#
# ~/.bashrc
#

# shellcheck disable=SC1090

export LFS=/mnt/lfs

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

launch () {
  nohup "$@" 1>/dev/null 2>&1 &
}

# util
alias ls='ls --color=auto'
alias la='ls -Alh'
alias lc='ls -CF'
alias ll='ls -lh'
alias grep='grep --color=auto'
alias less='less -FKNUX'
alias .='pwd'
alias ..='cd ..'
alias ~='cd ~'
fframe () {
	if [ -z "$1" ] || ! [ -f "$1" ]; then
		printf 'Please enter the file the first frame of which is to be extracted\n'
	fi
	file_xt=$(printf '%s' "$1" | awk -F. '{print $NF}')
	if [ -z "$2" ] || [ -f "$2" ]; then
		# can file extensions ever be properly handled? this is a problem throughout
		temp_file=$(mktemp --suffix=."$file_xt")
		ffmpeg -i "$1" -vf "select=eq(n\,0)" -q:v 3 "$temp_file"
		rm -v "$1"
		mv -v "$temp_file" "$1"
	else
		if ! printf '%s' "$2" | grep -qE "\.$file_xt$"; then
			output="$2.$file_xt"
		else
			output="$2"
		fi
		ffmpeg -i "$1" -vf "select=eq(n\,0)" -q:v 3 "$output"
		while : ; do
			printf 'Delete original file? (y/n) '
			read -r yn
			case "$(printf '%s' "$yn" | awk '{printf tolower($0)}')" in
				'y'|'yes') rm -v "$1"; break;;
				'n'|'no') break;;
				*) printf 'Please enter y or n!\n'
			esac
		done
	fi
}
# make this better? fold into lf (which could have flags)?
fsort () {
  if [ -d "$1" ]; then
    wd="$1"
  else
    wd='.'
  fi
  f="$(lf "$wd")"
  f_total="$(printf '%s' "$f" | head -n1)"
  printf '%s' "$f" | sed 1d | sort -hk5,5
  printf '%s\n' "$f_total"
}
lf () {
  # I think this is necessary but maybe not
  if [ -d "$1" ]; then
    wd="$1"
  else
    wd='.'
  fi
  pwd_total="$(du -hd0 "$wd" 2>/dev/null | awk '{print $1}')"
  printf 'total %s\n' "$pwd_total"
  # -H flag? is dereferencing non-cl symlinks even possible?
  # use find? (shellcheck recommended)
  ls -Alh "$wd" 2>/dev/null | sed 1d | while read -r file; do
    name="$(printf '%s' "$file" | awk '{print $9}')"
    if [ -d "$wd/$name" ]; then
      fake_size="$(printf '%s' "$file" | awk '{print $5}')"
      real_size="$(du -hd0 "$wd/$name" 2>/dev/null | awk '{print $1}')"
      space_count="$(printf '%s' "$real_size" | wc -m)"
      space_count=$((5-space_count))
      spacing=''
      for i in $(seq 1 "$space_count"); do
        spacing="$spacing "
      done
      printf '%s\n' "$file" | sed "s/[ ]\{1,\}$fake_size/$spacing$real_size/"
    else
      printf '%s\n' "$file"
    fi
  done
}
s () {
	if [ $# -eq 0 ]; then
		sudo "$(history -p '!!')"
	else
		sudo "$@"
	fi
}
extract () {
  del=1 # more elegant way to do this?
  [ -n "$2" ] && del=0
	if [ -f "$1" ]; then
		case "$1" in
      *.tar.bz2) tar xjf "$1";;
      *.tar.gz) tar xzf "$1";;
      *.bz2) bunzip2 "$1";;
      *.rar) rar x "$1";;
      *.gz) gunzip "$1";;
      *.tar) tar xf "$1";;
      *.tbz2) tar xjf "$1";;
      *.tgz) tar xzf "$1";;
      *.zip) unzip "$1";;
      *.Z) uncompress "$1";;
      *.7z) 7zz x "$1";;
      *.pxz) pixz -d "$1";;
			*) del=1 && printf "'%s' cannot be extracted via extract()\n" "$1"
		esac
    [ $del -eq 0 ] && rm "$1"
	else
		printf "'%s' is not a valid file\n" "$1"
	fi
}
gt () {
	path="$_"
  if ! [ "$(printf '%s' "$path" | cut -c-1)" = '/' ]; then
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
# improve tolerance of separators (,/[]/{}) somehow?
# make this more complex and allow nesting? ideas:
# name: }
# indentation
bs () {
  [ $# -ne 2 ] && printf 'Please provide two arguments!\n' && return 1
  if [ -f "$1" ]; then
    file="$1" && tg="$2"
  elif [ -f "$2" ]; then
    file="$2" && tg="$1"
  else
    printf 'Please provide a file!\n' && return 2
  fi
  indent="$(grep -E "^[  ]*$tg: \[" <"$file" | sed "s/\\t/    /g; s/\(^[  ]*\)$tg: \[/\1/" | head -n1 | tr -d '\n')"
  linedent="$(printf '%s' "$indent" | wc -m)" && linedent=$((linedent+2))
  # this version should be working but it's not, and worse yet, it's legitimately four HUNDRED times slower...tf 
  #indent='' && left='' && right='' && spacer=''
  #while IFS= read -r line; do
  #  line="$(printf '%s' "$line" | sed "s/\\t/    /g")"
  #  if printf '%s' "$line" | grep -qE "^[ ]*$tg: [[\{]"; then
  #    if printf '%s' "$line" | grep -q '\['; then
  #      left='\[' && right='\]' && spacer='\n'
  #    else
  #      left='{' && right='}' && spacer=' '
  #    fi
  #    indent="$(printf '%s' "$line" | sed "s/^\([ ]*\)$tg: $left.*$/\1/")"
  #  elif printf '%s' "$line" | grep -qE "^$indent$right"; then
  #    indent='' && left='' && right='' && spacer=''
  #  elif [ -n "$indent" ] && printf '%s' "$line" | grep -qE "^$indent  "; then
  #    printf '%s' "$line" | rev | sed "s/[ ]\{2,\}/$spacer/g" | rev
  #  fi
  #done <"$file"
  #{ grep -qE "$tg: \[" <"$file" && grep -q "^\]" <"$file"; } &&
  #tr -d '\n' <"$file" | sed "s/^.*$tg: \[$indent  \(.*\)$/\1/" | rev | sed "s/^.*\]$indent\(.*\)$/\1/" | rev | sed "s/[ ]\{$linedent,\}/\\n/g" && printf '\n'
  # nesting isn't possible because sed doesn't support negative lookahead--use grep w perl regex? awk? (look on stack overflow)
  # tr -d '\n' <"$file" | sed "s/^.*$indent$tg: \[$indent  \([^]]*[^ ]\)$indent\].*$/\1/; s/$indent  /\\n/g" && printf '\n'
  # one potential option (credit to https://unix.stackexchange.com/questions/78472/print-lines-between-start-and-end-using-sed)
  grep -q "$tg: \[" <"$file" 2>/dev/null && sed -ne "/^$indent$tg: \[$/,/^$indent\]$/{//!p}" <"$file" | sed "s/$indent  //"
  grep -q "$tg: \{" <"$file" 2>/dev/null && sed -ne "/^$indent$tg: \{$/,/^$indent\}$/{//!p}" <"$file" | sed "s/$indent  //" | tr '\n' ' '
  # rather than naively converting to spaces, maybe wrap everything in "'s for preservation as parameters? would make sense
  #{ grep -qE "$tg: \{" <"$file" && grep -q "^\}" <"$file"; } && printf '\n' && tr -d '\n' <"$file" | tr ']}' '\n' | grep -E "^.*$tg: \{" | sed "s/^.*$tg: {\(.*\)$/\1/" | tr ',' ' '
}

# is this double underscore convention sensible? is there a better one?
__catn_r () {
	while IFS= read -r line; do
		printf '%s\n' "$line"
		nested_file=$(printf '%s' "$line" | tr -d '\- :\t' | sed "s|~|$HOME|")
		if [ -n "$nested_file" ] && [ -f "$nested_file" ]; then
			COL_COUNT=$(stty size </dev/tty | awk '{print $2}')
			nlen=${#nested_file}
			[ $((COL_COUNT % 2)) -ne $((nlen % 2)) ] && tick=">"
			if [ $((COL_COUNT - nlen - 26)) -lt 2 ]; then
				printf '\n====Nested file %s read by catn:====\n\n' "$tick$nested_file"
			else
				# could do these in the loop, but it's not actually worth it in terms of parsimony
				printf '\n'
				for i in $(seq 1 $((COL_COUNT - nlen - 26))); do
					printf '='
					[ $((i)) -eq $(((COL_COUNT - nlen - 26) / 2)) ] && printf 'Nested file %s read by catn:' "$nested_file"
				done
				printf '\n\n'
			fi
			__catn_r "$nested_file"
			printf '\n'
			for i in $(seq 1 $((COL_COUNT))); do
				printf '='
			done
			printf '\n'
		fi
	done < "$1"
}
catn () {
	for p; do
		if ! [ -f "$p" ]; then
			printf 'All parameters must be files!\n'
			exit 1
		fi
	done
	# way to avoid two of the same loop in a row? (somehow scrutinizing param list holistically, e.g.)
	for p; do
		__catn_r "$p"
	done
}

# bin
prog () {
  list="$(pacman -Qen)"
  case "$1" in
    *'x'*) list="$(printf '%s' "$list" | grep -vE '^alsa|amd|base|ca-certificates|gnome|gst|gtk|lib|linux|perl|python|systemd|xorg')";;&
    *'v'*) list="$(printf '%s' "$list" | awk '{print $1}')"
  esac
  list="$(printf '%s' "$list" | sed 's/$/, /' | tr -d '\n' | rev | cut -c3- | rev)"
  printf '%s\n' "$list"
}
completion () {
  for i in $(seq 1 ${#1}); do
    tg="$(printf '%s' "$1" | cut -c-"$i")"
    cmd_num="$(compgen -c | grep -c "^$tg")"
    { [ "$(compgen -c | grep -c "^$1")" -eq "$cmd_num" ] || [ "$i" -eq "${#1}" ]; } && break
  done
  printf 'Number of characters until autocompletion: %s\n' "$i"
  top_chars="$(compgen -c | grep -v '^[^a-z]' | sed 's/^\([a-z]\).*$/\1/' | sort | uniq -c | sort -n | awk '{print $2}' | head -n3 | tr '\n' '/' | rev | cut -c2- | rev)"
  ! printf '%s' "$top_chars" | grep -q "$(printf '%s' "$1" | cut -c-1)" && printf 'Try a name starting with %s, these are the three least common starting letters for commands in this shell\n' "$top_chars"
}
alias lemonbarrc="pkill lemonbar; ~/.config/lemonbar/lemonbarrc | lemonbar -p -g \$(xwininfo -root | grep 'Width' | cut -c 10-)x40 & disown && \$SHELL"
alias shellcheck='shellcheck --shell sh'
alias lynx='lynx -cfg=~/.config/lynx/lynx.cfg'
alias fiirefox='firefox --new-instance --private-window'
alias quutebrowser='qutebrowser :jmatrix-toggle'
lcompletion () {
	complete -W "$(prog xv | sed "s/,//g") $(alias -p | sed "s/^alias \(.*\)='.*$/\1/") $(find "$HOME"/src/ -maxdepth 1 -type d | sed '1d; s/^src\/\(.*\)/\1/')" l
}
lcompletion
# still need to quote anything containing an ampersand (or presumably semicolon)...maybe there's a better way to do this? or you should just use a launcher lol
l () {
  # this method isn't as foolproof as I thought
  if alias -p | grep -q "^alias $1='"; then
    full_command=$(alias -p | grep "^alias $1='" | sed "s/^alias $1='\(.*\)'$/\1/; s/'\\\'//g")
    program_name=$(printf '%s' "$full_command" | awk '{print $1}')
    shift
    # why doesn't this work if full_command is quoted?
    launch $full_command "$@"
    hangup "$program_name"
  else
    launch "$@"
    hangup "$1"
  fi
}
hangup () {
  list="$(pgrep -f "$1")"
  dif='0'
  until [ "$dif" = '1' ]; do
    # apparently, pgrepping a process with a name >15 characters automatically fails :/ idk how to work around that
    diff -q <( printf '%s' "$list" ) <( pgrep -f "$1" ) 1>/dev/null 2>&1
    dif="$?"
  done
  exit 0
}
alias mppv='mpv --loop-playlist --shuffle'
alias novel='l libreoffice --writer ~/docs/novel.txt'
alias reader="find ~/docs -name '*.pdf' | xargs xpdf & disown && exit 0"
alias xonotic='xonotic-sdl'
alias tor="sudo tor 2>/dev/null"
alias herst='wg-quick up ~/.config/wireguard/her.st/antimetabolism.conf'
alias calc="printf 'Make sure to exit() when done\n'; python"
py () {
  python -m venv ~/.venv/
  . ~/.venv/bin/activate
  printf "'deactivate' to exit\n"
}

# my bin
pwgen () {
	chars=''
	[ -z "$2" ] && set "$1" '-1'
	until [ "${#chars}" = "$2" ]; do
		char=$(printf '%b\n' "$(curl --silent "https://www.random.org/cgi-bin/randbyte?nbytes=1&format=d")" | awk '{printf "%c\n", $1}' | tr -d '\0')
		case "$char" in
			$1*) chars="$chars$char"; printf '%s' "$char"
		esac
	done
	printf '\n'
}
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
clog () {
  # figure out a more efficient way to do this!
  if [ -f "$HOME/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/miyu_at_witch.crft.sh/$(date +%Y_%m_%d).log" ]; then
    cat "$HOME/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/miyu_at_witch.crft.sh/$(date +%Y_%m_%d).log"
  elif [ -f "$HOME/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/admin_at_witch.crft.sh/$(date +%Y_%m_%d).log" ]; then
    cat "$HOME/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/admin_at_witch.crft.sh/$(date +%Y_%m_%d).log"
  else
    printf 'Sorry, no log currently exists for today.\n'
  fi
}
# this modular design just kinda...doesn't work? lol
# should every option (or only certain options?) be singular instead (i.e. 'h' instead of *'h'*)?
miyu () {
	if [ -z "$1" ]; then
		out=$(cat <( cut -d' ' -f9- ~/docs/logs/miyu_out.txt ) <( cat ~/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/{miyu,admin}_at_witch.crft.sh/* | cut -d' ' -f4- ))
	else
		do_full='false'
		case "$1" in
			*'h'*) printf 'Usage: miyu [option(s)]\n  a: print only messages from anti\n  m: print only messages from miyu\n  f: print messages in full (uncut)\n  x: print statistics Xtremely fast (no byte count, slight inaccuracy)\n  e: pretty print /me\n  r: use regex to cut message metadata\n'; return 0;;
			*'x'*) wc ~/docs/logs/miyu_out.txt <( cat ~/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/{miyu,admin}_at_witch.crft.sh/* ) | tr -d '\n' | awk '{print " "$1+$5, ($2-$1*8)+($6-$5*3)}'; return 0;;
			'f') cat ~/docs/logs/miyu_out.txt ~/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/{miyu,admin}_at_witch.crft.sh/*; return 0;;
			*'f'*) do_full='true'
		esac
		out=$(cat ~/docs/logs/miyu_out.txt ~/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/{miyu,admin}_at_witch.crft.sh/*)
		case "$1" in
			# using out rather than just retyping to preserve order (first option a or m supersedes)
			*'a'*) out=$(printf '%s' "$out" | grep -E ' antimetabolism: | anti: | - anti@witch.crft.sh: | - me: ');;&
			*'m'*) out=$(printf '%s' "$out" | grep -E ' miyu: | - miyu@witch.crft.sh: | - admin@witch.crft.sh: ');;&
			*'e'*) out=$(printf '%s' "$out" | sed 's/ - [*]\([^ ]\{1,\}\) \(.*\)$/ - \1: (\/me)\1 \2/; s/(\/me)me/(\/me)anti/; s/(\/me)anti\@witch\.crft\.sh/(\/me)anti/; s/(\/me)\(.*\)\@chat\.her\.st/(\/me)\1/; s/(\/me)\(.*\)\@witch\.crft\.sh/(\/me)\1/');;&
			*'r'*) out=$(printf '%s' "$out" | sed 's/^.*[miyu|miyu\@witch\.crft\.sh|admin| - admin\@witch\.crft\.sh|antimetabolism|anti| - me| - anti\@witch\.crft\.sh]: \(.*\)$/\1/'); do_full='true'
		esac
		[ "$do_full" = 'false' ] && out=$(cat <( printf '%s' "$out" | grep -E ' antimetabolism: | miyu: ' | cut -d' ' -f9- ) <( printf '%s' "$out" | grep -E ' - me: | - miyu@witch.crft.sh: | - admin@witch.crft.sh: ' | cut -d' ' -f4- ))
	fi
	printf '%s\n' "$out"
}
# this could be universalized like fm, but atm that doesn't seem worth it (the cost of typing out the full path vs. the lack of other sizeable groups of numbered files on my system)
vnc () {
	which='anti'
	[ -n "$1" ] && which="$1"
	num="$(find ~/auds/miyu -maxdepth 1 -type f | sed "s/^.*for.*$which\([0-9]*\)\..*$/\1/" | sort -n | tail -n1)"
	printf '%b' "Current: $num, next: $((num+1))\n"
}
alias Internet='sudo Internet'
I () {
  # flags?
  if ! ping -c1 -W5 archlinux.org 1>/dev/null 2>&1; then
    while : ; do
      printf 'Run Internet? (y/n) '
      read -r response
      case "$(printf '%s' "$response" | awk '{printf tolower($0)}')" in
        'y'|'yes') printf 'Running Internet...\n' && Internet; break;;
        *) printf 'Good luck, see you on the other side\n' && break
      esac
    done
  else
    printf 'You have Internet!\n'
  fi
}
# credit to http://refuge3noitqegmmjericvur54ihyj7tsfyfwdblitaeaqu2koi7iuqd.onion/index.php?topic=391.0
ipaddr () {
	if pgrep '^tor$' 1>/dev/null; then printf 'tor network IP address: %b\nregular network IP address: ' "$(curl --silent -x socks5://127.0.0.1:9050 api.ipify.org)"; fi
	printf '%b\n' "$(curl --silent api.ipify.org)"
}

PS1='\[\e[32m\][\u@\h \W]\$ \[\e[0m\]'
