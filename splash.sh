#!/bin/bash

set -e

# arguments
MODE=$1
VERSION=$2
ECLIPSE_BASE_PATH=$3

# replacement regexs
REGEX_ECLIPSE_INI='s/org.eclipse.epp.package.common/org.emoflon.splash/g'
REGEX_CONFIG_INI='s/osgi.splashPath=platform\\:\/base\/plugins\/org.eclipse.epp.package.common/osgi.splashPath=platform\\:\/base\/plugins\/org.emoflon.splash/g'

# Check for existing ENVs
if [[ -z "$MODE" ]]; then
	echo "=> No mode ENV found. Exit."; exit 1 ;
fi
if [[ -z "$VERSION" ]]; then
	echo "=> No version ENV found. Exit."; exit 1 ;
fi
if [[ -z "$ECLIPSE_BASE_PATH" ]]; then
	echo "=> No Eclipse base path ENV found. Exit."; exit 1 ;
fi

if [[ "$MODE" = "img" ]]; then
    convert ./resources/emoflon-splash_template.png -font Liberation-Sans -pointsize 24 -draw "gravity south fill white text 0,15 '${VERSION}'" splash.bmp
elif [[ "$MODE" = "deploy" ]]; then
    mkdir -p $ECLIPSE_BASE_PATH/plugins/org.emoflon.splash

    # check if splash.bmp exists
    if [[ ! -f splash.bmp ]]; then
        echo "=> splash.bmp not found. Exit."; exit 1 ;
    fi

    mv splash.bmp $ECLIPSE_BASE_PATH/plugins/org.emoflon.splash
    if [[ "$(uname)" == "Darwin" ]]; then
        # sed on macOS needs a special treatment
        # https://stackoverflow.com/questions/19456518/error-when-using-sed-with-find-command-on-os-x-invalid-command-code
        sed -i.fix $REGEX_ECLIPSE_INI $ECLIPSE_BASE_PATH/eclipse.ini
        sed -i.fix $REGEX_CONFIG_INI $ECLIPSE_BASE_PATH/configuration/config.ini
        rm -f $ECLIPSE_BASE_PATH/eclipse.ini.fix
        rm -f $ECLIPSE_BASE_PATH/configuration/config.ini.fix
    else
        sed -i $REGEX_ECLIPSE_INI $ECLIPSE_BASE_PATH/eclipse.ini
        sed -i $REGEX_CONFIG_INI $ECLIPSE_BASE_PATH/configuration/config.ini
    fi
fi
