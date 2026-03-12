#!/bin/bash

set -e

DEPENDENCIES=("wget" "curl" "unzip" "zip")

# Displays the given input including "=> " on the console.
log () {
	echo "=> $1"
}

# Actually install all dependencies
for p in ${DEPENDENCIES[@]}; do
    choco install $p --no-progress
done
