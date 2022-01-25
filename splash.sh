#!/bin/bash

set -e

VERSION=$1
convert ./resources/emoflon-splash_template.png -pointsize 24 -draw "gravity south fill white text 0,15 '${VERSION}'" splash.bmp
mkdir -p ./eclipse/plugins/org.emoflon.splash
mv splash.bmp ./eclipse/plugins/org.emoflon.splash
sed -i 's/org.eclipse.epp.package.common/org.emoflon.splash/g' ./eclipse/eclipse.ini
sed -i 's/osgi.splashPath=platform\\:\/base\/plugins\/org.eclipse.platform/osgi.splashPath=platform\\:\/base\/plugins\/org.emoflon.splash/g' ./eclipse/configuration/config.ini
