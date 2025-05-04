#! /bin/bash

echo "[+] Initializing"
echo "[+] Creating directories if not exist."

DOWNDIR=~/Downloads/
OLDDIR="$DOWNDIR/Old"
mkdir -p "$OLDDIR" "$DOWNDIR/Videos" "$DOWNDIR/Documents" "$DOWNDIR/Compressed" "$DOWNDIR/Images" "$DOWNDIR/Scripts"
CLEANLOG="$DOWNDIR/cleanup.log"

echo "[+] Checking for 7 days old files"

find "$DOWNDIR" -maxdepth 1 -type f -mtime +7 -print0 | while IFS= read -r -d '' file; do
	mv "$file" "$OLDDIR"
	echo "$(date): Moved $file to $OLDDIR" >> "$CLEANLOG"
done

echo "[+] Analizing extesions and moving"

find "$DOWNDIR" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
	# File extesions definition and organizing
	ext="${file##*.}"
	ext="${ext,,}"

	case "$ext" in
		mp4|mkv|webm) dest="$DOWNDIR/Videos" ;;
		pdf|doc|docx|odt|txt) dest="$DOWNDIR/Documents" ;;
		zip|tar|gz|rar|7z) dest="$DOWNDIR/Compressed" ;;
		jpg|jpeg|png|gif|webp) dest="$DOWNDIR/Images" ;;
		html|css|py|sh|json) dest="$DOWNDIR/Scripts" ;;
		*) dest="" ;;	
	esac	

	if [[ -n "$dest" ]]; then
		mv "$file" "$dest/"
		echo "$(date): Moved $file to $dest/" >> "$CLEANLOG"
	fi
done

echo "[+] Checking for uncategorized files..."

EXCLUDED_NAMES=("Old" "Videos" "Documents" "Compressed" "Images" "Scripts" "cleanup.log")
GREP_PATERN=$(IFS=\| ; echo "${EXCLUDED_NAMES[*]}")
LEFTOVERS_FILE="/tmp/leftovers.txt"

> "$LEFTOVERS_FILE"

while IFS= read -r item; do
	name=$(basename "$item")
	skip=0
	for ex in "${EXCLUDED_NAMES[@]}"; do
		[[ "$name" == "$ex" ]] && skip=1 && break
	done
	[[ $skip -eq 0 ]] && echo "$item" >> "$LEFTOVERS_FILE"
done < <(find "$DOWNDIR" -mindepth 1 -maxdepth 1 \( -type f -o -type d \))


if [[ -s "$LEFTOVERS_FILE" ]]; then
	echo "[!] The following items in Downloads were not categorized. Please review manually:"
	cat "$LEFTOVERS_FILE"
	echo "[!] Uncategorized items:" >> "$CLEANLOG"
    cat "$LEFTOVERS_FILE" >> "$CLEANLOG"
else
	echo "[+] No uncategorized files or directories left in Downloads."
fi
