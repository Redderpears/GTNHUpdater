#!/bin/bash

echo $'CLIENT pack update for GTNH, created with 2.8.3.\n'
echo $'\e[31mThis .sh should be placed in the folder with the .minecraft, one folder deeper than .../instances'
echo $'\tPARENT_FOLDER/NEW_SERVER_FOLDER/this.sh\n'
echo $'\tPARENT_FOLDER/NEW_SERVER_FOLDER/new_server.zip\n'
echo $'\tPARENT_FOLDER/OLD_SERVER_FOLDER.\n\e[0m'

CURR_DIRECTORY="$(realpath $(dirname "$0")/.minecraft)"

if [[ ! -d $CURR_DIRECTORY ]]; then
	echo $'This wasn\'t placed in the folder with .minecraft! \nPlace this next to .minecraft in the instance you\'re trying to update.'
	exit 0
fi

read -p $'Please provide the name of the old client instance name in Prism:\n' PREV_NAME
INSTANCES_DIR="$(dirname "$0")/../"

# echo "$(realpath $INSTANCES_DIR)"
MATCHING_INSTANCE="$(grep -Rli "name=$PREV_NAME$" --include="instance.cfg" "$INSTANCES_DIR")"

MATCHING_INSTANCE_COUNT=$(printf '%s\n' "$MATCHING_INSTANCE" | wc -l)

if [ -z "$MATCHING_INSTANCE" ]; then
	MATCHING_INSTANCE_COUNT=0;
fi

if (( MATCHING_INSTANCE_COUNT != 1)); then
	echo "Found $MATCHING_INSTANCE_COUNT instances with this name."
	exit 0
fi

PREV_DIR=$(realpath $(dirname "$MATCHING_INSTANCE"))
echo "Found an instance named $PREV_NAME at $PREV_DIR"

if [[ "$PREV_DIR" == "$(realpath $(dirname "$0"))" ]]; then
	read -p $'You\'re trying to update your instance with itself. Are you okay?\n>' sanity_check
	if [[ ! $sanity_check == [Yy] ]]; then
		exit 0
	else
		echo "Liar."
		exit 0
	fi
fi

PREV_DIR="$PREV_DIR/.minecraft"

echo "Looking at $PREV_DIR..."

SAVES_DIR="$PREV_DIR/saves"
BACKUPS_DIR="$PREV_DIR/backups"
JOURNEYMAP_DIR="$PREV_DIR/journeymap"
VISUALPROSPECTING_DIR="$PREV_DIR/visualprospecting"
TCNODETRACKER_DIR="$PREV_DIR/TCNodeTracker"
SCHEMATICS_DIR="$PREV_DIR/schematics"
RESOURCEPACKS_DIR="$PREV_DIR/resourcepacks"
SHADERPACKS_DIR="$PREV_DIR/shaderpacks"
LOCALCONFIG_F="$PREV_DIR/localconfig.cfg"
BOTANIAVARS_F="$PREV_DIR/BotaniaVars.dat"
OPTIONS_F="$PREV_DIR/options.txt"
OPTIONSNF_F="$PREV_DIR/optionsnf.txt"
SERVERS_F="$PREV_DIR/servers.dat"

read -p $'\n'"$SAVES_DIR"$'\n'"$BACKUPS_DIR"$'\n'"$JOURNEYMAP_DIR"$'\n'"$VISUALPROSPECTING_DIR"$'\n'"$TCNODETRACKER_DIR"$'\n'"$SCHEMATICS_DIR"$'\n'"$RESOURCEPACKS_DIR"$'\n'"$SHADERPACKS_DIR"$'\n'"$LOCALCONFIG_F"$'\n'"$BOTANIAVARS_F"$'\n'"$OPTIONS_F"$'\n'"$OPTIONSNF_F"$'\n'"$SERVERS_F"$'\n\n'"These files will be moved to the directory"$'\n\e[31m'"THAT THIS SCRIPT IS PLACED IN, FROM $PREV_NAME"$'\e[0m\nContinue?\n>' ans
if [[ ! $ans == [Yy] ]]; then
	echo "ABORTED"
	exit 0
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

copy_over_dir 	"$SAVES_DIR" saves
copy_over_dir	"$BACKUPS_DIR" backups
copy_over_dir	"$JOURNEYMAP_DIR" journeymap
copy_over_dir	"$VISUALPROSPECTING_DIR" visualprospecting
copy_over_dir	"$TCNODETRACKER_DIR" TCNodeTracker
copy_over_dir	"$SCHEMATICS_DIR" schematics
copy_over_dir	"$RESOURCEPACKS_DIR" resourcepacks
copy_over_dir	"$SHADERPACKS_DIR" shaderpacks
copy_over_f	"$LOCALCONFIG_F"
copy_over_f	"BOTANIAVARS_F"
copy_over_f	"OPTIONS_F"
copy_over_f	"OPTIONSNF_F"
copy_over_f	"SERVERS_F"
