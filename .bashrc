#
# ~/.bashrc
#

# shellcheck disable=SC1090

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# util
alias ls='ls --color=auto'
alias la='ls -Alh'
alias lc='ls -CF'
alias ll='ls -lh'
alias grep='grep --color=auto'
alias nv='nvim'
alias vim='nvim'
alias less='less -FKNUX'
alias .='pwd'
alias ..='cd ..'
alias ~='cd ~'
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
  # identical time to du -sh...idk why I did it this way
  #printf 'total %s\n' "$(du -hd0 "$wd" 2>/dev/null | awk '{print $1}')"
  # -H flag? is dereferencing non-cl symlinks even possible?
  #ls -Alh "$wd" 2>/dev/null | sed 1d | while read -r file; do
  #  name="$(printf '%s' "$file" | awk '{print $9}')"
  #  if [ -d "$wd/$name" ]; then
  #    fake_size="$(printf '%s' "$file" | awk '{print $5}')"
  #    real_size="$(du -hd0 "$wd/$name" 2>/dev/null | awk '{print $1}')"
  #    space_count="$(printf '%s' "$real_size" | wc -m)"
  #    space_count=$((5-space_count))
  #    spacing=''
  #    for i in $(seq 1 "$space_count"); do
  #      spacing="$spacing "
  #    done
  #    printf '%s\n' "$file" | sed "s/[ ]\{1,\}$fake_size/$spacing$real_size/"
  #  else
  #    printf '%s\n' "$file"
  #  fi
  #done
  #du_list="$(for file in .[^.]* *; do du -hd0 "./$file"; done | sort -k2,2 | awk '{print $1}')"
  # this is literally as fast as the old version, fuck! it seems like it's essentially impossible to keep it speedy by doing anything but looping over all lines once and somehow gleaning the appropriate data, as in the Stack Overflow solution (either setting or getting array indices)
  # and it turns out it doesn't even work properly...;'{
  #ls_list="$(sort -k2,2 <( ls -Alh "$wd" 2>/dev/null | sed 1d | awk '{print "ilovemiyu " $9 " " $0}'; du -hd0 "$wd"/.[^.]* "$wd"/* 2>/dev/null))"
  #ls_length="$(printf '%s' "$ls_list" | wc -l)"
  #count='0'
  #printf '%s' "$ls_list" | while read -r line; do
  #  count="$((count+1))"
  #  if [ "$((count%2))" = '1' ]; then
  #    double_line="$(printf '%s' "$line" | awk '{print $1}')"
  #  else
  #    printf '%s' "$line" | awk '{print $3 " " $4 " " $5 " " $6 " "}' | tr -d '\n'
  #    printf '%s' "$double_line " | tr -d '\n'
  #    printf '%s\n' "$line" | awk '{print $8 " " $9 " " $10 " " $11 " "}'
  #  fi
  #done
  # credit to: https://stackoverflow.com/questions/1019116/using-ls-to-list-directories-and-their-total-sizes#comment101944659_28582709
  # formatting is impossible to get right in one statement (because I think it would take algorithms, but maybe it wouldn't), as are filenames with multiple spaces. it also doesn't do a total (but this is easily fixed)
  { cd "$wd" || exit 1; } && (du -hd0 .[^.]* * 2>/dev/null; ls -Alh 2>/dev/null) | awk '{ if($1 == "total") {X = 1} else if (!X) {SIZES[$2] = $1} else { printf("%10s %2s %-6s %-5s %-4s %3s %2s %5s %s\n", $1, $2, $3, $4, SIZES[$9], $6, $7, $8, $9) } }'
  cd "$OLDPWD" || exit 2
}
s () {
	if [ $# -eq 0 ]; then
		cmd="$(history -p '!!')"
		sudo "$cmd"
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
alias firefox="firefox --new-instance --url 'about:blank' 2>/dev/null"
complete -W "$(prog xv | sed "s/,//g")" l
l () {
  # this method isn't as foolproof as I thought
  list="$(pgrep "$1")"
  dif='0'
  nohup "$@" &
  until [ "$dif" = '1' ]; do
    diff -q <( printf '%s' "$list" ) <( pgrep "$1" ) 1>/dev/null 2>&1
    dif="$?"
  done
  exit 0
}
alias tor="sudo tor 2>/dev/null"
alias keepass='keepassxc ~/docs/antinomicon.kdbx'
alias herst='wg-quick up ~/.config/wireguard/her.st/antimetabolism.conf'
py () {
  python -m venv ~/.venv/
  . ~/.venv/bin/activate
  printf "'deactivate' to exit\n"
}

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
clog () {
  cat "$HOME/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/miyu_at_witch.crft.sh/$(date +%Y_%m_%d).log"
}
miyu () {
  [ -n "$1" ] && case "$1" in
  *'n'*) printf '%b' "$(cat ~/docs/logs/miyu_out.txt ~/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/miyu_at_witch.crft.sh/* | sed -E 's/^.*(miyu\@witch\.crft\.sh|miyu|me): (.*)$/(\1) \2/')\n";;
  *'m'*) printf '%b' "$(cat ~/docs/logs/miyu_out.txt ~/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/miyu_at_witch.crft.sh/* | sed -E 's/^.*(miyu\@witch\.crft\.sh|miyu|me): (.*)$/\2/; s/^.* ([[:digit:]]\{4\}|-) [*]me (.*)$/(\/me)anti \2/; s/^.* ([[:digit:]]\{4\}|-) [*]miyu\@witch\.crft\.sh (.*)$/(\/me)miyu \2/')\n"
  esac
  [ -z "$1" ] && printf '%b\n' "$(cut -d' ' -f9- "$HOME/docs/logs/miyu_out.txt" && cat "$HOME"/.local/share/profanity/chatlogs/anti_at_witch.crft.sh/miyu_at_witch.crft.sh/* | cut -d' ' -f4-)"
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

# srv
alias ipaddr='ip addr show | grep global | sed "s/^.* \(\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}\)\/.*$/\1/"'
alias sshsetup="printf 'Run ssh-add [path to key] once inside and do not forget to pkill ssh-agent once done!\n'; eval \"\$(ssh-agent -s)\""
alias pandoraemon='ssh lore@192.168.1.14'

PS1='\[\e[32m\][\u@\h \W]\$ \[\e[0m\]'
