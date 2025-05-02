#! /bin/bash

REPO=$HOME/Documents/GitHub/hyprbrighter/.config/ 

CONFIGS=(btop cava ctpv fastfetch hypr hyprshot kitty MangoHud mpv nwg-look rofi set_wallpaper swaync swww wal waybar wlogout yazi zsh)

#LOG_FILE="$HOME/Documents/GitHub/hyprbrighter/.config/autolog/usrcfgbk-$(date '+%Y-%m-%d-%H:%M:%S').log"
LOG_FILE="$HOME/Documents/tests/log$(date '+%Y-%m-%d-%H:%M:%S').log"
mkdir -p "$(dirname "$LOG_FILE")"


{
	echo "Backup started: $(date)"
	for cfg in "${CONFIGS[@]}"; do
		SRC="$HOME/.config/$cfg"
		DEST="$REPO/$cfg"
		
		if [ -d "$SRC" ]; then
			echo "[+] Found $cfg."
			rsync -a --delete "$SRC/" "$DEST/"
		else
			echo "[+] Directory not found $cfg - ignoring."
		fi
	done

	cd "$REPO" || exit
	
	git checkout main

	if [[ -n $(git status --porcelain) ]]; then
		echo "[+] changes detected - syncing with remote first..."
		git stash push --include-untracked -m "temp-backup-before-rebase"
		
		

		if git pull --rebase origin main; then
			git stash pop
		else
			echo "[-] Rebase failed. Aborting and restoring stash..."
			git rebase --abort
			git stash pop
			exit 1
		fi

		echo "[+] Making commit and push..."
		git add .
		git commit -m "Automatic backup $(date '+%Y-%m-%d %H:%M:%S')"
		git push
		echo "[+] Backup sent to GitHub."
	else
		echo "[+] Any new changes has been detected - nothing has sent."
	fi
	echo "[+END] Backup done: $(date)"
	echo "----------------------------"
} >> "$LOG_FILE" 2>&1

REPOLOG="$REPO/autolog"
mkdir -p "$REPOLOG"
cp "$LOG_FILE" "$REPOLOG"
