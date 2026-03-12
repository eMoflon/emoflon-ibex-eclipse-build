#!/bin/bash

set -e

DEPENDENCIES=("p7zip" "coreutils" "grep" "wget" "curl")

# Displays the given input including "=> " on the console.
log () {
	echo "=> $1"
}

# Installs the given package via brew if it is not already installed.
# Reference: https://apple.stackexchange.com/a/425118
brew_install() {
    log "Installing $1."
    if brew list $1 &>/dev/null; then
        log "${1} is already installed."
    else
        brew install $1 && log "$1 is installed."
    fi
}

# Actually install all dependencies
for p in ${DEPENDENCIES[@]}; do
    brew_install $p
done
