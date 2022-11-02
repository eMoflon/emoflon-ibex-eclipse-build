#!/bin/bash

#
# Config
#

ECLIPSE_ARCHIVE=eclipse-emoflon-windows-dev # Name of the archive to download
FORCE_DOWNLOAD=0                            # 1 = force download of new archive
TARGET_DIR=$1                               # Target directory
API_URL="https://api.github.com/repos/eMoflon/emoflon-ibex-eclipse-build/releases/latest"

set -e
START_PWD=$PWD

#
# Utils
#

# Displays the given input including "=> " on the console.
log () {
	printf "=> $1\n"
}

#
# Script
#

if [[ -z "$TARGET_DIR" ]]; then
    log "Parameter for target directory was empty. Exit.\n   Call script with the parameter, e.g.:\n   ./eclipse-update.sh /home/mkratz/eclipse-apps/emt"
    exit 1;
fi

log "Started Eclipse install/update script."
cd $TARGET_DIR

# Get eclipse
if [[ ! -f "./$ECLIPSE_ARCHIVE.zip" ]] || [[ "$FORCE_DOWNLOAD" = "1" ]]; then
    TAG=$(curl -s $API_URL \
        | grep "\"name\"\: \"v" \
        | cut -d : -f 2,3 \
        | tr -d \" |tr -d ,)
	log "Downloading latest eMoflon::IBeX Eclipse archive from Github.\nRelease:$TAG"
	curl -s $API_URL \
        | grep "$ECLIPSE_ARCHIVE.*zip" \
        | cut -d : -f 2,3 \
        | tr -d \" \
        | wget -qi -
fi

if [[ -f "./eclipse" ]]; then
    log "Rename old Eclipse folder."
    mv ./eclipse ./eclipse-old
fi

log "Extract new Eclipse archive."
unzip -qq -o $ECLIPSE_ARCHIVE.zip

if [[ -f "./eclipse-old" ]]; then
    log "Remove old Eclipse folder."
    rm -rf ./eclipse-old  
fi

cd $START_PWD
log "Updated successfully."
