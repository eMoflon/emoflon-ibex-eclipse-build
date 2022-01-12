#!/bin/bash

set -e

#
# config
#

VERSION="2021-12"
ARCHIVE_FILE="eclipse-modeling-$VERSION-R-linux-gtk-x86_64.tar.gz"
OUTPUT_FILE="eclipse-emoflon-linux-user.zip"
MIRROR="https://ftp.fau.de"
UPDATESITES="http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/,http://hallvard.github.io/plantuml/,https://hipe-devops.github.io/HiPE-Updatesite/hipe.updatesite/,http://download.eclipse.org/viatra/updates/release/latest,http://www.kermeta.org/k2/update,https://emoflon.org/emoflon-ibex-updatesite/snapshot/updatesite/,https://www.genuitec.com/updates/devstyle/ci/,https://download.eclipse.org/releases/2021-12"

#
# utils
#

# Parses a given list and returns the packages as String (comma separated).
parse_package_list () {
	OUTPUT=""
	while IFS= read -r line
	do
        OUTPUT+=$line","
	done < "$1"
	echo "$OUTPUT"
}

# Installs a given list of packages from a given update site.
install_packages () {
./eclipse/eclipse -application org.eclipse.equinox.p2.director \
        -repository "$1" \
        -installIU "$(parse_package_list $2)"
}

if [[ ! -f "./$ARCHIVE_FILE" ]]; then
	echo "=> Downloading Eclipse $VERSION archive from $MIRROR."
	wget -q $MIRROR/eclipse/technology/epp/downloads/release/$VERSION/R/$ARCHIVE_FILE
fi

echo "=> Clean-up Eclipse folder and untar."
rm -rf ./eclipse/*
tar -xzf eclipse-modeling-$VERSION-R-linux-gtk-x86_64.tar.gz

echo "=> Install eclipse plug-ins."
install_packages "$UPDATESITES" "./packages/xtext-packages.list"
install_packages "$UPDATESITES" "./packages/plantuml-packages.list"
install_packages "$UPDATESITES" "./packages/hipe-packages.list"
install_packages "$UPDATESITES" "./packages/viatra-packages.list"
install_packages "$UPDATESITES" "./packages/kermeta-packages.list"
install_packages "$UPDATESITES" "./packages/emoflon-packages.list"
install_packages "$UPDATESITES" "./packages/theme-packages.list"

echo "=> Clean-up old archives and create new archive."
rm -f ./$OUTPUT_FILE
zip -q -r $OUTPUT_FILE eclipse

echo "=> Build finished."
