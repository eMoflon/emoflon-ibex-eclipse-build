#!/bin/bash

set -e

MODE=$1
VERSION=$2
ECLIPSE_BASE_PATH=$3
if [[ "$MODE" = "img" ]]; then
    convert ./resources/emoflon-splash_template.png -font Liberation-Sans -pointsize 24 -draw "gravity south fill white text 0,15 '${VERSION}'" splash.bmp
elif [[ "$MODE" = "deploy" ]]; then
    mkdir -p $ECLIPSE_BASE_PATH/plugins/org.emoflon.splash
    mv splash.bmp $ECLIPSE_BASE_PATH/plugins/org.emoflon.splash
    sed -i 's/org.eclipse.epp.package.common/org.emoflon.splash/g' $ECLIPSE_BASE_PATH/eclipse.ini
    sed -i 's/osgi.splashPath=platform\\:\/base\/plugins\/org.eclipse.platform/osgi.splashPath=platform\\:\/base\/plugins\/org.emoflon.splash/g' $ECLIPSE_BASE_PATH/configuration/config.ini
fi
