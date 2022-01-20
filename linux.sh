#!/bin/bash

set -e

#
# Config
#

VERSION="2021-12"
ARCHIVE_FILE="eclipse-modeling-$VERSION-R-linux-gtk-x86_64.tar.gz"
OUTPUT_FILE_PREFIX="eclipse-emoflon-linux"
MIRROR="https://ftp.fau.de"
UPDATESITES="http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/,http://hallvard.github.io/plantuml/,https://hipe-devops.github.io/HiPE-Updatesite/hipe.updatesite/,http://download.eclipse.org/viatra/updates/release/latest,http://www.kermeta.org/k2/update,https://emoflon.org/emoflon-ibex-updatesite/snapshot/updatesite/,https://www.genuitec.com/updates/devstyle/ci/,https://download.eclipse.org/releases/2021-12,https://www.codetogether.com/updates/ci/"

# Array with the order to install the plugins with.
ORDER=("xtext" "plantuml" "hipe" "viatra" "kermeta" "emoflon" "theme")

#
# Utils
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
./eclipse/eclipse -nosplash \
		-application org.eclipse.equinox.p2.director \
        -repository "$1" \
        -installIU "$(parse_package_list $2)"
}

# Displays the given input including "=> " on the console.
log () {
	echo "=> $1"
}

#
# Script
#

# Check if script needs to download the initial Eclipse archive.
if [[ ! -f "./$ARCHIVE_FILE" ]]; then
	log "Downloading Eclipse $VERSION archive from $MIRROR."
	wget -q $MIRROR/eclipse/technology/epp/downloads/release/$VERSION/R/$ARCHIVE_FILE
fi

# Parse arguments
if [[ -z "$1" ]]; then
	log "No parameter(s) given. Exit."; exit 1 ;
fi
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -m|--mode) MODE="$2"; shift ;;
		--skip-theme) SKIP_THEME=1 ;;
        *) log "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

if [[ "$MODE" = "user" ]]; then
	INSTALL_EMOFLON=1
	OUTPUT_FILE="$OUTPUT_FILE_PREFIX-user.zip"
elif [[ "$MODE" = "dev" ]]; then
	INSTALL_EMOFLON=0
	OUTPUT_FILE="$OUTPUT_FILE_PREFIX-dev.zip"
else
	log "Mode argument invalid."; exit 1 ;
fi

log "Clean-up Eclipse folder and untar."
rm -rf ./eclipse/*
tar -xzf eclipse-modeling-$VERSION-R-linux-gtk-x86_64.tar.gz

log "Install Eclipse plug-ins."
for p in ${ORDER[@]}; do
	# Check if eMoflon packages must be skipped (for dev builds).
	if [[ "$p" = "emoflon" ]] && [[ $INSTALL_EMOFLON -eq 0 ]]; then
		log "Skipping plug-in: $p."
		continue
	fi
	
	# Check if Dark Theme packages must be skipped (for CI builds = completely headless).
	if [[ "$p" = "theme" ]] && [[ $SKIP_THEME -eq 1 ]]; then
		log "Skipping plug-in: $p."
		continue
	fi
    log "Installing plug-in: $p."
    install_packages "$UPDATESITES" "./packages/$p-packages.list"
done

# Install com.seeq.eclipse.importprojects (by hand because there is no update site)
log "Install Eclipse import projects plug-in."
# https://github.com/seeq12/eclipse-import-projects-plugin/raw/master/jar/com.seeq.eclipse.importprojects_1.4.0.jar
wget -P eclipse/plugins https://github.com/seeq12/eclipse-import-projects-plugin/raw/master/jar/com.seeq.eclipse.importprojects_1.4.0.jar

log "Clean-up old archives and create new archive."
rm -f ./$OUTPUT_FILE
zip -q -r $OUTPUT_FILE eclipse

log "Build finished."
