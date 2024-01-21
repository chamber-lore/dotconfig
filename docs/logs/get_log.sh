#!/bin/sh

file=$(mktemp)
file2=$(mktemp)
printf '' > "$1".txt
sqlite3 gayjim.db "SELECT time, kind, message FROM logs JOIN jids ON logs.jid_id=jids.jid_id WHERE jids.jid LIKE '%$1%';" | tr '|' ' ' > "$file"
if grep -vqE '^[0-9]' "$file"; then
	while IFS='' read -r line; do
		if [ "$(printf '%s' "$line" | awk '{print NF}')" != '1' ]; then
			buffer=$(printf '%s' "$line" | awk '{print $1" "$2" "}')
			printf '%s\n' "$line" >> "$file2"
		else
			printf -- "$buffer%s\n" "$line" >> "$file2"
		fi
	done < "$file"
	sort -sk1,1 "$file2" > "$1".txt
else
	cp "$file" "$1".txt
fi
