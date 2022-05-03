#!/bin/bash

set -e

# Parse arguments
if [[ -z "$1" ]]; then
	echo "=> No parameter(s) given. Exit."; exit 1 ;
fi
while [[ "$#" -gt 0 ]]; do
	case $1 in
		-m|--mode) MODE="$2"; shift ;;
		-o|--os) OS="$2"; shift ;;
		--skip-theme) SKIP_THEME=1 ;;
		*) echo "=> Unknown parameter passed: $1"; exit 1 ;;
	esac
	shift
done

# TODO: Check if env VERSION is set

#
# Config and URLs
#

VERSION=$VERSION # version comes from the CI env
ARCHIVE_FILE_LINUX="eclipse-modeling-$VERSION-R-linux-gtk-x86_64.tar.gz"
ARCHIVE_FILE_WINDOWS="eclipse-modeling-$VERSION-R-win32-x86_64.zip"
ARCHIVE_FILE_MACOS="eclipse-modeling-$VERSION-R-macosx-cocoa-x86_64.dmg"
OUTPUT_FILE_PREFIX_LINUX="eclipse-emoflon-linux"
OUTPUT_FILE_PREFIX_WINDOWS="eclipse-emoflon-windows"
OUTOUT_FILE_PREFIX_MACOS="eclipse-emoflon-macos"
MIRROR="https://ftp.fau.de"
UPDATESITES="https://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/,https://hallvard.github.io/plantuml/,https://hipe-devops.github.io/HiPE-Updatesite/hipe.updatesite/,https://www.kermeta.org/k2/update,https://emoflon.org/emoflon-ibex-updatesite/snapshot/updatesite/,https://www.genuitec.com/updates/devstyle/ci/,https://download.eclipse.org/releases/$VERSION,https://www.codetogether.com/updates/ci/"
EMOFLON_HEADLESS_SRC="https://api.github.com/repos/eMoflon/emoflon-headless/releases/latest"

# Import plug-in:
IMPORT_PLUGIN_VERSION="2.0.0"
IMPORT_PLUGIN_FILENAME="com.seeq.eclipse.importprojects_$IMPORT_PLUGIN_VERSION.jar"
IMPORT_PLUGIN_SRC="https://api.github.com/repos/maxkratz/eclipse-import-projects-plugin/releases/tags/v$IMPORT_PLUGIN_VERSION"

# Array with the order to install the plugins with.
ORDER_LINUX=("xtext" "plantuml" "hipe" "kermeta" "misc" "emoflon-headless" "emoflon" "theme")

#
# Configure OS specific details
#

if [[ "$OS" = "linux" ]]; then
	ARCHIVE_FILE=$ARCHIVE_FILE_LINUX
	OUTPUT_FILE_PREFIX=$OUTPUT_FILE_PREFIX_LINUX
	ORDER=("${ORDER_LINUX[@]}")
elif [[ "$OS" = "windows" ]]; then
	ARCHIVE_FILE=$ARCHIVE_FILE_WINDOWS
	OUTPUT_FILE_PREFIX=$OUTPUT_FILE_PREFIX_WINDOWS
	# Windows now uses the linux install order too
	ORDER=("${ORDER_LINUX[@]}")
elif [[ "$OS" = "macos" ]]; then
	ARCHIVE_FILE=$ARCHIVE_FILE_MACOS
	OUTPUT_FILE_PREFIX=$OUTOUT_FILE_PREFIX_MACOS
	# Lets try with linux install order
	ORDER=("${ORDER_LINUX[@]}")
else
	echo "=> OS $OS not known."
	exit 1
fi

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
	if [[ "$OS" = "linux" ]]; then
		./eclipse/eclipse -nosplash \
			-application org.eclipse.equinox.p2.director \
			-repository "$1" \
			-installIU "$(parse_package_list $2)"
	elif [[ "$OS" = "windows" ]]; then
		./eclipse/eclipsec.exe -nosplash \
			-application org.eclipse.equinox.p2.director \
			-repository "$1" \
			-installIU "$(parse_package_list $2)"
	elif [[ "$OS" = "macos" ]]; then
		chmod +x ./eclipse/Eclipse.app/Contents/MacOS/eclipse
		./eclipse/Eclipse.app/Contents/MacOS/eclipse -nosplash \
			-application org.eclipse.equinox.p2.director \
			-repository "$1" \
			-installIU "$(parse_package_list $2)"
	fi
}

# Displays the given input including "=> " on the console.
log () {
	echo "=> $1"
}

# Setup the local updatesite of the emoflon headless
setup_emoflon_headless_local_updatesite () {
	log "Create local tmp folder."
	rm -rf ./tmp && mkdir -p ./tmp/emoflon-headless

	log "Get emoflon-headless and extract its updatesite."
	EMOFLON_HEADLESS_LATEST_UPDATESITE=$(curl -s $EMOFLON_HEADLESS_SRC \
		| grep "updatesite.*zip" \
		| cut -d : -f 2,3 \
		| tr -d \")
	wget -P ./tmp/emoflon-headless -qi $EMOFLON_HEADLESS_LATEST_UPDATESITE

	unzip ./tmp/emoflon-headless/updatesite.zip -d tmp/emoflon-headless

	# Append local folder to path (has to be absolute and, therefore, dynamic)
	if [[ ! -z ${GITHUB_WORKSPACE} ]] && [[ "$OS" = "windows" ]]; then
		log "Using a Github-hosted runner on Windows."
		UPDATESITES+=",file:/D:/a/emoflon-eclipse-build/emoflon-eclipse-build/tmp/emoflon-headless/"
	elif [[ "$OS" = "linux" ]]; then
		log "Using a runner on Linux."
		UPDATESITES+=",file://$PWD/tmp/emoflon-headless/"
	elif [[ "$OS" = "windows" ]]; then
		log "Using a runner on Windows."
		UPDATESITES+=",file://$(echo $PWD | sed -e 's/\/mnt\///g' | sed -e 's/^\///' -e 's/\//\\/g' -e 's/^./\0:/')\tmp\emoflon-headless\\"
	elif [[ "$OS" = "macOS" ]]; then
		log "Using a runner on macOS."
		UPDATESITES+=",file://$PWD/tmp/emoflon-headless/"
	fi
}

# Install eclipse import projects plug-in
install_eclipse_import_projects () {
	log "Install Eclipse import projects plug-in."
	IMPORT_PROJECTS_JAR=$(curl -s $IMPORT_PLUGIN_SRC \
		| grep "$IMPORT_PLUGIN_FILENAME" \
		| cut -d : -f 2,3 \
		| tr -d \")
	wget -P eclipse/plugins -qi $IMPORT_PROJECTS_JAR
}

# Install custom global configuration
install_global_eclipse_settings () {
	log "Install global Eclipse settings."
	cp ./resources/emoflon.properties ./eclipse
	echo "-Declipse.pluginCustomization=emoflon.properties" >> ./eclipse/eclipse.ini
}


#
# Script
#

# Check if script needs to download the initial Eclipse archive.
if [[ ! -f "./$ARCHIVE_FILE" ]]; then
	log "Downloading Eclipse $VERSION archive from $MIRROR."
	wget -q $MIRROR/eclipse/technology/epp/downloads/release/$VERSION/R/$ARCHIVE_FILE
fi

if [[ "$MODE" = "user" ]]; then
	INSTALL_EMOFLON=1
	OUTPUT_FILE="$OUTPUT_FILE_PREFIX-user.zip"
elif [[ "$MODE" = "dev" ]]; then
	INSTALL_EMOFLON=0
	OUTPUT_FILE="$OUTPUT_FILE_PREFIX-dev.zip"
elif [[ "$MODE" = "hipedev" ]]; then
	INSTALL_EMOFLON=0
	SKIP_HIPE=1
	OUTPUT_FILE="$OUTPUT_FILE_PREFIX-dev-hipe.zip"
else
	log "Mode argument invalid."; exit 1 ;
fi

# Setup the emoflon headless (special snowflake because of the zipped update site)
setup_emoflon_headless_local_updatesite

# Extract new Eclipse
if [[ "$OS" = "linux" ]]; then
	log "Clean-up Eclipse folder and untar."
	rm -rf ./eclipse/*
	tar -xzf eclipse-modeling-$VERSION-R-linux-gtk-x86_64.tar.gz
elif [[ "$OS" = "windows" ]]; then
	log "Clean-up Eclipse folder and unzip."
	rm -rf ./eclipse/*
	unzip -qq -o eclipse-modeling-$VERSION-R-win32-x86_64.zip
elif [[ "$OS" = "macos" ]]; then
	log "Clean-up Eclipse folder and unzip."
	rm -rf ./eclipse/*
	7z x $ARCHIVE_FILE_MACOS
	# Rename folder because "Eclipse" is inconsistent
	mv Eclipse eclipse
fi

# Install global Eclipse settings from config file
install_global_eclipse_settings

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

	# Check if HiPE must be skipped (for hipe-dev builds).
	if [[ "$p" = "hipe" ]] && [[ $SKIP_HIPE -eq 1 ]]; then
		log "Skipping plug-in: $p."
		continue
	fi
	log "Installing plug-in: $p."
	install_packages "$UPDATESITES" "./packages/$p-packages.list"
done

# Install com.seeq.eclipse.importprojects (by hand because there is no public update site)
install_eclipse_import_projects

# Deploy custom splash image
if [[ $SKIP_THEME -eq 1 ]]; then
	# Skip UI customization for CI builds
	log "Skipping custom splash image."
else
	log "Deploy custom splash image."
	chmod +x splash.sh && ./splash.sh deploy
fi

log "Clean-up old archives and create new archive."
rm -f ./$OUTPUT_FILE
zip -q -r $OUTPUT_FILE eclipse

log "Build finished."
