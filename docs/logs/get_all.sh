#!/bin/sh

file=$(mktemp)
sqlite3 gayjim.db "SELECT jid FROM jids;" > "$file"
while IFS= read -r jid; do
	theirname=$(printf '%s' "$jid" | awk -F@ '{print $1}')
	if printf '%s' "$jid" | grep -q '/'; then
		theirname="$theirname-$(printf '%s' "$jid" | awk -F/ '{print $NF}')"
	fi
	./get_log.sh "$theirname"
	convxlog /home/proanti/docs/logs/"$theirname".txt "antimetabolism" "$theirname"
	rm "$theirname".txt
done < "$file"
rm "$file"
