#!/bin/sh

for audio_file in ./audio/*; do
	# no clue why the first end bracket is necessary but I hope it doesn't fuck anything up in the future!
	i=$(printf '%s' "$audio_file" | sed "s/^\.\/audio\///; s/\].*$//")
	video_file=$(find ./video -name "$i*")
	ffmpeg -i "$video_file" -i "$audio_file" -c copy ./music/"$i].mkv"
done

# prompt, action if y, action if n (optional), error message (optional)
# ^ but then you can't have no action if n but an error message...fuck (another one for the pile)
# is it possible to have a middle parameter (#2 e.g.) be optional?
get_yn () {
	if [ -z "$1" ] || [ -z "$2" ]; then
		#printf 'Insufficient parameters provided.\n'
		exit 1
	fi
	while : ; do
		printf '%s (y/n) ' "$1"
		read -r response
		case "$(printf '%s' "$response" | awk '{printf tolower($0)}')" in
			'y'|'yes') $2; break;;
			'n'|'no')
				# formatting? (can this all be one line with ;, e.g.?)
				[ -n "$3" ] && $3
				break
				;;
			*)
				if [ -n "$4" ]; then
					printf '%s\n' "$4"
				else
					printf 'Please enter y or n!\n'
				fi
		esac
	done
}

get_yn 'Delete all files from the audio dir?' 'rm ./audio/*'
get_yn 'Delete all files from the video dir?' 'rm ./video/*'
