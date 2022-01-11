#!/bin/bash

set -e

#
# config
#

VERSION="2021-12"
ARCHIVE_FILE="eclipse-modeling-$VERSION-R-linux-gtk-x86_64.tar.gz"

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
	wget https://ftp.fau.de/eclipse/technology/epp/downloads/release/$VERSION/R/$ARCHIVE_FILE
fi

rm -rf ./eclipse/*
tar -xzf eclipse-modeling-$VERSION-R-linux-gtk-x86_64.tar.gz

install_packages "http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/" "./packages/xtext-dependencies.list"
install_packages "http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/" "./packages/xtext-packages.list"
install_packages "http://hallvard.github.io/plantuml/" "./packages/plantuml-packages.list"
install_packages "https://download.eclipse.org/releases/2021-12" "./packages/hipe-dependencies.list"
install_packages "https://hipe-devops.github.io/HiPE-Updatesite/hipe.updatesite/" "./packages/hipe-packages.list"
install_packages "https://download.eclipse.org/releases/2021-12" "./packages/viatra-dependencies.list"
install_packages "http://download.eclipse.org/viatra/updates/release/latest" "./packages/viatra-packages.list"
install_packages "http://www.kermeta.org/k2/update" "./packages/kermeta-packages.list"
install_packages "http://download.eclipse.org/modeling/emft/mwe/updates/releases/" "./packages/emoflon-dependencies.list"
install_packages "https://emoflon.org/emoflon-ibex-updatesite/snapshot/updatesite/" "./packages/emoflon-packages.list"
install_packages "https://download.eclipse.org/releases/2021-12" "./packages/theme-dependencies.list"
install_packages "https://www.codetogether.com/updates/ci/" "./packages/theme-dependencies2.list"
install_packages "https://www.genuitec.com/updates/devstyle/ci/" "./packages/theme-packages.list"

echo "=> Build finished."
