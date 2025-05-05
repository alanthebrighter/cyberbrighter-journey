#!/usr/bin/env bash

DOWNTRASH=~/Downloads/Old/
TRASHDIRFILES=~/.local/share/Trash/files/
TRASHDIRINFO=~/.local/share/Trash/info/
mkdir -p "$TRASHDIRFILES" "$TRASHDIRINFO"

CLEANLOG=~/Downloads/cleanup.log
mkdir -p "$(dirname "$CLEANLOG")"
touch "$CLEANLOG"

echo -e "\n========== $(date) ==========" | tee -a "$CLEANLOG"
echo "[+] Checking for old files in $DOWNTRASH" | tee -a "$CLEANLOG"

find "$DOWNTRASH" -maxdepth 1 -type f -mtime +14 -print0 | while IFS= read -r -d '' file; do
	echo "[>] Moving $file to the Trash." | tee -a "$CLEANLOG" 
	mv "$file" "$TRASHDIRFILES"
	echo "$(date): Moved $file to Trash from '$DOWNTRASH'" | tee -a $CLEANLOG
done

echo
echo "[!] Taking out the Trash." | tee -a "$CLEANLOG"

TRASHFILES=$(find "$TRASHDIRFILES" -maxdepth 1 -type f | wc -l)
TRASHDIRS=$(find "$TRASHDIRFILES" -mindepth 1 -maxdepth 1 -type d | wc -l)

echo "[?] $TRASHDIRS Directories and $TRASHFILES Files were found in the Trash." 
read -p "[?] Do you want to clean the Trash? (Y/n) " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
	find "$TRASHDIRFILES" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
	find "$TRASHDIRINFO" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
	echo "[+] $TRASHDIRS Directories and $TRASHFILES Files were deleted." | tee -a "$CLEANLOG"
else
	echo "[x] Operation canceled."
fi

echo
echo "[!] Cleaning Package Cache." | tee -a "$CLEANLOG"

echo "[!] This can delete useful packages"
read -p "[?] Do you want to continue? (Y/n) " answerpkg

if [[ "$answerpkg" =~ ^[Yy]$ ]]; then
	echo "[+] Cleaning the Packages."
	echo "$(date): Running 'pacman -Sc'" | tee -a "$CLEANLOG"
	sudo pacman -Sc | tee -a "$CLEANLOG" 
else
	echo "[!] Operation canceled."
fi

echo
echo "[!] Cleaning Orphaned Packages." | tee -a "$CLEANLOG"

ORPHANS=$(pacman -Qdtq)

if [[ -z "$ORPHANS" ]]; then
	echo "[!] No Orphan Packages were found." | tee -a "$CLEANLOG"
else
	echo "[?] These Orphan Packages were found."
	echo "[!] $ORPHANS" 
	read -p "[?] Do you want to remove them? (Y/n) " answerop
	if [[ "$answerop" =~ ^[Yy]$ ]]; then
		echo "[+] Removing Orphan Packages."
		echo "$(date): Removing orphan packages: $ORPHANS" | tee -a "$CLEANLOG"
		sudo pacman -Rns $ORPHANS | tee -a "$CLEANLOG"
	else
		echo "[-] Operation canceled."
	fi
fi

echo
echo "[!] Everything should look cleaner now!"





