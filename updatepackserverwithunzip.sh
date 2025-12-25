#!/bin/bash

echo $'SERVER pack update for GTNH, created with 2.8.3.\n'
echo $'\e[31mThis .sh should be placed in the folder in which you intend to unzip the new install, along with the .zip.\n\nFOR EXAMPLE,\nin a folder named PARENT_FOLDER, there should be these three files/directories:\n'
echo $'\tPARENT_FOLDER/NEW_SERVER_FOLDER/this.sh\n'
echo $'\tPARENT_FOLDER/NEW_SERVER_FOLDER/new_server.zip\n'
echo $'\tPARENT_FOLDER/OLD_SERVER_FOLDER.\n\e[0m'

CURR_DIRECTORY=$(realpath "$(dirname "$0")")


readarray -t ZIP_FILES < <(find "$CURR_DIRECTORY" -maxdepth 1 -type f -name "*.zip")

printf '%s\n' "${ZIP_FILES[@]}"
ZIP_COUNT=${#ZIP_FILES[@]}

if (( ZIP_COUNT > 1 )); then
	echo "There can only be one zip file alongside the .sh. Found $ZIP_COUNT"
	exit 0
elif (( ZIP_COUNT == 1 )); then

	ZIP_DIR=${ZIP_FILES[0]}
	echo "Found $ZIP_DIR..."
	unzip "$ZIP_DIR"
	rm "$ZIP_DIR"

	readarray -t ZIP_FILES < <(find "$CURR_DIRECTORY" -maxdepth 1 -type f -name "*.zip")

	printf '%s\n' "${ZIP_FILES[@]}"
	ZIP_COUNT=${#ZIP_FILES[@]}
	if (( ZIP_COUNT != 1 )); then
		echo "There can only be one zip file alongside the .sh. Found $ZIP_COUNT. This should not happen!"
		exit 0
	fi

	ZIP_DIR=${ZIP_FILES[0]}
	echo "Found $ZIP_DIR..."
	unzip "$ZIP_DIR" -x "journeymap/*" "serverutilities/*"
	rm "$ZIP_DIR"

else
	if [[ ! -f "$CURR_DIRECTORY/eula.txt" ]]; then
		echo "You don't have a eula or any zip in this folder. Please install the proper server pack."
		exit 0
	fi
fi

read -p $'Please provide the name of the old server folder:' PREV_NAME
PREV_DIRECTORY=$"$(dirname "$0")/../$PREV_NAME"

while true; do
	if [ -d "$PREV_DIRECTORY" ]; then
		PREV_DIRECTORY=$(realpath "$PREV_DIRECTORY")
		echo "Found directory $PREV_DIRECTORY"
		break
	fi
	echo "Could not find directory $PREV_DIRECTORY" 
	read -p $'Please provide the name of the old server folder:' PREV_NAME
	PREV_DIRECTORY=$"$(dirname "$0")/../$PREV_NAME"
done

echo ""
echo "The previous install was found at $PREV_DIRECTORY"
echo "This install will be merged to $CURR_DIRECTORY"

if [[ ! -d $PREV_DIRECTORY ]]; then
	echo "YOU SUCK $PREV_DIRECTORY"
fi

echo "Found a directory at $PREV_DIRECTORY ..."

if [ -f "$PREV_DIRECTORY/eula.txt" ]; then
	EULA_STATE=$(grep "=" "$PREV_DIRECTORY/eula.txt" | cut -d '=' -f 2)
	# echo $EULA_STATE
	if [ ! "$EULA_STATE" = "true" ]; then
		read -p $'Your previous instance folder did not have an accepted EULA, \nis this the correct folder?\n>' ans
		if [[ ! $ans == [Yy] ]]; then
			exit 0
		fi
	else
		read -p $'Your previous instance folder had an accepted eula. \nContinue? \n>' ans
		if [[ ! $ans == [Yy] ]]; then
			exit 0
		fi
	fi
	unset ans
else
	echo "Could not find a eula."
	exit 0
fi

read -p $'What is the name of your previous world folder? \nLeave empty for \"World\"' WORLD_NAME

if [ -z $WORLD_NAME ]; then
	WORLD_NAME="World"
fi

while [ ! -d "$PREV_DIRECTORY/$WORLD_NAME/playerdata" ]; do
	echo "Could not find the playerdata directory, suggesting that this is not a world file"
	read -p $'What is the name of your previous world folder? \nLeave empty for \"World\"' WORLD_NAME
	if [ -z $WORLD_NAME ]; then
		WORLD_NAME="World"
	fi
done

WORLD_DIR="$PREV_DIRECTORY/$WORLD_NAME"
JOURNEYMAP_DIR="$PREV_DIRECTORY/journeymap"
SERVERUTILITIES_DIR="$PREV_DIRECTORY/serverutilities"
BACKUPS_DIR="$PREV_DIRECTORY/backups"
VISUALPROSPECTING_DIR="$PREV_DIRECTORY/visualprospecting"
SERVERPROPERTIES_F="$PREV_DIRECTORY/server.properties"
WHITELIST_F="$PREV_DIRECTORY/whitelist.json"
OPS_F="$PREV_DIRECTORY/ops.json"
BANNED_IPS_F="$PREV_DIRECTORY/banned-ips.json"
BANNED_PLAYERS_F="$PREV_DIRECTORY/banned-players.json"

read -p $'\n'"$WORLD_DIR"$'\n'"$JOURNEYMAP_DIR"$'\n'"$SERVERUTILITIES_DIR"$'\n'"$BACKUPS_DIR"$'\n'"$VISUALPROSPECTING_DIR"$'\n'"$WHITELIST_F"$'\n'"$OPS_F"$'\n'"$BANNED_IPS_F"$'\n'"$BANNED_PLAYERS_F"$'\n\n'"These files will be moved to the directory"$'\n\e[31m'"THAT THIS SCRIPT IS PLACED IN, FROM $WORLD_NAME"$'\e[0m\nContinue?\n>' ans

if [[ ! $ans == [Yy] ]]; then
	echo "ABORTED"
	return 0
fi
echo "CONTINUED"

copy_over_dir() {
	local OLD_DIR="$1"
	local NEW_NAME="$2"
	if [ -d $OLD_DIR ]; then
		echo "$OLD_DIR Found!"
		local NEWWORLD_DIR="$CURR_DIRECTORY/$NEW_NAME"
		cp -r -f "$OLD_DIR" "$NEWWORLD_DIR"
		echo "$NEWWORLD_DIR done!"
	fi
}

copy_over_f() {
	local OLD_F="$1"
	if [ -f $OLD_F ]; then
		echo "$OLD_F Found!"
		cp -f "$OLD_F" "$CURR_DIRECTORY"
		echo "$OLD_F done!"
	fi
}

copy_over_dir "$WORLD_DIR" "$WORLD_NAME"
copy_over_dir "$JOURNEYMAP_DIR" journeymap
copy_over_dir "$SERVERUTILITIES_DIR" serverutilities
copy_over_dir "$BACKUPS_DIR" backups
copy_over_dir "$VISUALPROSPECTING_DIR" visualprospecting
copy_over_f "$SERVERPROPERTIES_F"
copy_over_f "$WHITELIST_F"
copy_over_f "$OPS_F"
copy_over_f "$BANNED_IPS_F"
copy_over_f "$BANNED_PLAYERS_F"

echo $'\e[31mSOME OF THESE MAY HAVE FAILED!\n If they did, it should be pretty obvious, and it should be mad about not having permission to change the file. \nThis means, when making the .zip, GTNH devs forgot to make some of the folders not root. Run as sudo if this happens\e[0m'
echo ""
echo "Don't forget to change:"
echo "Pollution"
echo "Wuss mode if you're into that"
echo "And any other configurations"
