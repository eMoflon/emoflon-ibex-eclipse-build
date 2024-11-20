#!/bin/bash

# This script patches the `Info.plist` file in the Eclipse.app to
# properly make/mark it executable.
#
# author: Max Kratz <maximilian.kratz@es.tu-darmstadt.de>
# date: 2024-11-15 

set -e

FILE="./Eclipse.app/Contents/Info.plist"
JAVA=$(/usr/libexec/java_home)
STRING="      <string>-vm</string><string>$JAVA/bin/java</string>"

if [ ! -f $FILE ]; then
    echo "=> Eclipse.app not found in local folder."
    exit 1;
fi

if grep -Fq "$STRING" $FILE > /dev/null
then
    echo "=> Info.plist already patched."
else
    echo "=> Patching Info.plist."
    sed -i -e '/.eclipse_keyring/a\'$'\n'"$STRING" $FILE
fi

sudo codesign --force --deep --sign - ./Eclipse.app
xattr -d com.apple.quarantine ./Eclipse.app || true

echo "=> Done."
