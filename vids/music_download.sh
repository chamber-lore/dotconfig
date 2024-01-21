#!/bin/sh

# handle the random failures to curl--at the very least report them to a logfile or something!

get_line () {
  	printf '%s' "$2" | sed -n "${1}p" | tr -d '\n'
}

if ! ping -c1 archlinux.org 2>/dev/null 1>&2; then
	printf 'No Internet connection. Check your router maybe?\n'
	exit 1
else
	# could use mktemp and write it to that file for a while read loop
	instance_list=$(curl --silent https://api.invidious.io/ | grep -B3 "<td><a href=\"https://" | grep 'https://' | sed "s/^.*<td><a href=\"https:\/\/\(.*\)\".*$/\1/" | shuf)
	instance_count=$(printf '%s\n' "$instance_list" | wc -l)
	for i in $(seq 1 $((instance_count))); do
		instance=$(get_line "$i" "$instance_list")
		# place this assignment above instance_list's:
		# file=$(mktemp)
		# printf '%s: ' "$instance" >> "$file"
		#curl --silent --max-time 10  -w '%{time_total}\n' "$instance" -o /dev/null >> "$file"
	#done
	#sort -nrk2 "$file" -o "$file"
	#instance=$(tail -n1 "$file" | awk '{print $1}')
		if ping -c1 "$instance" 2>/dev/null 1>&2; then
			break
		fi
		if [ "$i" = "$instance_count" ]; then
			printf "Can't find a working Invidious instance. Check https://invidious.io maybe?\n"
			exit 2
		fi
	done
	printf 'Using Invidious instance https://%s\n' "$instance"
fi

# figure out how quoting works, once and for all (or maybe just for once)
length="$(wc -l <./music.txt)"
position=0
while IFS= read -r term; do
	term=$(printf '%s' "$term" | sed "s/ /+/g; s/&/and/g" | tr -d "()'\\/[]")
	position=$((position+1))
	# find a way to color in the position indicator somehow? (maybe grep isn't the most efficient lol) (but on the other hand, just having your PS1 be green takes a hot minute)
	printf 'Finding best link to song: %s (%s/%s) from\n' "$term" "$position" "$length"
	invidious=$(curl --silent "https://$instance/search?q=$term")
	titlinks="$(printf '%s' "$invidious" | grep -E "<a href=\"/watch\?v=.{11}\"")"
	titles="$(printf '%s' "$titlinks" | sed "s/^.*<a href=\".*\"><p dir=\"auto\">\(.*\)<\/p><\/a>$/\1/")"
	num_results="$(printf '%s' "$titles" | wc -l)"
	links="$(printf '%s' "$titlinks" | sed "s/^.*<a href=\"\(.*\)\"><p dir=\"auto\">.*<\/p><\/a>$/https:\/\/www.youtube.com\1/")"
	results=''
	for i in $(seq 1 $((num_results))); do
		title="$(get_line "$i" "$titles")"
  		link="$(get_line "$i" "$links")"
		result=$(printf '%s. Title: %s, URL: %s\n' "$i" "$title" "$link")
		results=$(printf '%s\n%s' "$results" "$result")
	done
	results=$(printf '%s' "$results" | grep -vE '^$')
	printf '%s\n' "$results"
	cutoff="$((num_results/8))"
	if printf '%s' "$results" | head -n"$cutoff" | grep -qi 'official'; then
		filtered_result=$(printf '%s\n' "$results" | head -n"$cutoff" | grep -i 'official' | head -n1 | sed "s/^.*URL: \(.*\)$/\1/")
	else
		filtered_result=$(printf '%s' "$results" | head -n1 | sed "s/^.*URL: \(.*\)$/\1/")
	fi
	printf 'Link:\n'
	printf '%s\n' "$results" | grep --color=auto "$filtered_result"
	printf 'Finding best format codes from:\n'
	formats=$(yt-dlp -F "$filtered_result" | sed '1,6d')
	# find a better way to just get the table (and not the "Downloading from YouTube..." type stuff)
	# flags (once you figure that whole thing out) to do manual selection a la traditional playvid? some automated way of handling selection criteria (cf. just editing this file)?
	printf '%s\n' "$formats"
	audio_format=$(printf '%s' "$formats" | grep 'audio only' | tail -n1)
	audio_format_code=$(printf '%s' "$audio_format" | awk '{print $1}')
	printf 'Format codes (audio, video):\n'
	# why does this fail sometimes?
	printf '%s\n' "$formats" | grep --color=auto "$audio_format"
	formats=$(printf '%s' "$formats" | grep 'video only')
	if printf '%s' "$formats" | grep -q '720p'; then
		video_format=$(printf '%s' "$formats" | grep '720p' | head -n1)
	else
		video_format=$(printf '%s' "$formats" | tail -n1)
	fi
	video_format_code=$(printf '%s' "$video_format" | awk '{print $1}')
	printf '%s\n' "$formats" | grep --color=auto "$video_format"
	yt-dlp -f "$audio_format_code" -P home:./audio "$filtered_result"
	yt-dlp -f "$video_format_code" -P home:./video "$filtered_result"
done <./music.txt
