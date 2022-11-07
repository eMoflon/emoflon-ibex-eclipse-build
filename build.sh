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

# Check for existing ENVs
if [[ -z "$VERSION" ]]; then
	echo "=> No version ENV found. Exit."; exit 1 ;
fi

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
UPDATESITES="https://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/,https://hallvard.github.io/plantuml/,https://hipe-devops.github.io/HiPE-Updatesite/hipe.updatesite/,https://www.kermeta.org/k2/update,https://emoflon.org/emoflon-ibex-updatesite/snapshot/updatesite/,https://www.genuitec.com/updates/devstyle/ci/,https://download.eclipse.org/releases/$VERSION,https://www.codetogether.com/updates/ci/,http://update.eclemma.org/,https://pmd.github.io/pmd-eclipse-plugin-p2-site/,https://checkstyle.org/eclipse-cs-update-site/,https://spotbugs.github.io/eclipse/"
EMOFLON_HEADLESS_SRC="https://api.github.com/repos/eMoflon/emoflon-headless/releases/latest"

# Import plug-in:
IMPORT_PLUGIN_VERSION="2.0.0"
IMPORT_PLUGIN_FILENAME="com.seeq.eclipse.importprojects_$IMPORT_PLUGIN_VERSION.jar"
IMPORT_PLUGIN_SRC="https://api.github.com/repos/maxkratz/eclipse-import-projects-plugin/releases/tags/v$IMPORT_PLUGIN_VERSION"

# Array with the order to install the plugins with.
ORDER_LINUX=("xtext" "plantuml" "hipe" "kermeta" "misc" "emoflon-headless" "emoflon" "theme" "additional")

#
# Configure OS specific details
#

if [[ "$OS" = "linux" ]]; then
	ARCHIVE_FILE=$ARCHIVE_FILE_LINUX
	OUTPUT_FILE_PREFIX=$OUTPUT_FILE_PREFIX_LINUX
	ORDER=("${ORDER_LINUX[@]}")
	ECLIPSE_BIN_PATH="./eclipse/eclipse"
	ECLIPSE_BASE_PATH="./eclipse"
elif [[ "$OS" = "windows" ]]; then
	ARCHIVE_FILE=$ARCHIVE_FILE_WINDOWS
	OUTPUT_FILE_PREFIX=$OUTPUT_FILE_PREFIX_WINDOWS
	# Windows now uses the linux install order too
	ORDER=("${ORDER_LINUX[@]}")
	ECLIPSE_BIN_PATH="./eclipse/eclipsec.exe"
	ECLIPSE_BASE_PATH="./eclipse"
elif [[ "$OS" = "macos" ]]; then
	ARCHIVE_FILE=$ARCHIVE_FILE_MACOS
	OUTPUT_FILE_PREFIX=$OUTOUT_FILE_PREFIX_MACOS
	# Lets try with linux install order
	ORDER=("${ORDER_LINUX[@]}")
	ECLIPSE_BIN_PATH="./eclipse/Eclipse.app/Contents/MacOS/eclipse"
	ECLIPSE_BASE_PATH="./eclipse/Eclipse.app/Contents/Eclipse"
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
	if [[ "$OS" = "macos" ]]; then
		chmod +x $ECLIPSE_BIN_PATH
	fi

	$ECLIPSE_BIN_PATH -nosplash \
			-application org.eclipse.equinox.p2.director \
			-repository "$1" \
			-installIU "$(parse_package_list $2)"
}

# Displays the given input including "=> " on the console.
log () {
	echo "=> $1"
}

# Setup the local updatesite of the emoflon headless
setup_emoflon_headless_local_updatesite () {
	log "Get emoflon-headless and extract its updatesite."
	if [[ ! -f "./tmp/emoflon-headless/updatesite.zip" ]]; then
		log "Create local tmp folder."
		rm -rf ./tmp && mkdir -p ./tmp/emoflon-headless
		log "emoflon-headless ZIP not found"
		CURL_RET=$(curl -s $EMOFLON_HEADLESS_SRC)
		log "curl: $CURL_RET"
		EMOFLON_HEADLESS_LATEST_UPDATESITE=$(echo "$CURL_RET" \
			| grep "updatesite.*zip" \
			| cut -d : -f 2,3 \
			| tr -d \")
		if [[ -z "${EMOFLON_HEADLESS_LATEST_UPDATESITE// }" ]]; then
			log "This runner propably reached it's Github API rate limit. Exit."
			exit 1
		fi

		log "Using updatesite URL $(echo $EMOFLON_HEADLESS_LATEST_UPDATESITE \
			| grep "/updatesite.*zip" \
			| sed 's/^[ \t]*//;s/[ \t]*$//')."
		wget -P ./tmp/emoflon-headless -qi $EMOFLON_HEADLESS_LATEST_UPDATESITE
	fi
	unzip ./tmp/emoflon-headless/updatesite.zip -d tmp/emoflon-headless

	# Append local folder to path (has to be absolute and, therefore, dynamic)
	if [[ ! -z ${GITHUB_WORKSPACE} ]] && [[ "$OS" = "windows" ]]; then
		log "Using a Github-hosted runner on Windows."
		UPDATESITES+=",file:/D:/a/emoflon-ibex-eclipse-build/emoflon-ibex-eclipse-build/tmp/emoflon-headless/"
	elif [[ "$OS" = "linux" ]]; then
		log "Using a runner on Linux."
		UPDATESITES+=",file://$PWD/tmp/emoflon-headless/"
	elif [[ "$OS" = "windows" ]]; then
		log "Using a runner on Windows."
		UPDATESITES+=",file://$(echo $PWD | sed -e 's/\/mnt\///g' | sed -e 's/^\///' -e 's/\//\\/g' -e 's/^./\0:/')\tmp\emoflon-headless\\"
	elif [[ "$OS" = "macos" ]]; then
		log "Using a runner on macOS."
		UPDATESITES+=",file://$PWD/tmp/emoflon-headless/"
	fi
}

# Install eclipse import projects plug-in
install_eclipse_import_projects () {
	log "Install Eclipse import projects plug-in."

	# Check if plugin JAR file is present at current location
	if [[ -f "com.seeq.eclipse.importprojects.jar" ]]; then
		log "Found local file of eclipse import plugin."
		mv ./com.seeq.eclipse.importprojects.jar $ECLIPSE_BASE_PATH/plugins
	else
		log "Download JAR file from Github API."
		IMPORT_PROJECTS_JAR=$(curl -s $IMPORT_PLUGIN_SRC \
			| grep "$IMPORT_PLUGIN_FILENAME" \
			| cut -d : -f 2,3 \
			| tr -d \")
		wget -P $ECLIPSE_BASE_PATH/plugins -qi $IMPORT_PROJECTS_JAR
	fi
}

# Install custom global configuration
install_global_eclipse_settings () {
	log "Install global Eclipse settings."
	if [[ "$MODE" = "user" ]]; then
		cp ./resources/emoflon_user.properties $ECLIPSE_BASE_PATH/emoflon.properties
	elif [[ "$MODE" = "dev" ]] || [[ "$MODE" = "hipedev" ]]; then
		cp ./resources/emoflon_dev.properties $ECLIPSE_BASE_PATH/emoflon.properties
	else
		log "Mode argument invalid."; exit 1 ;
	fi
	echo "-Declipse.pluginCustomization=emoflon.properties" >> $ECLIPSE_BASE_PATH/eclipse.ini
}

# Remove all configured update sites
remove_update_sites () {
	log "Remove all update sites."
	UPDATE_SITE_CONFIG_PATH="$ECLIPSE_BASE_PATH/p2/org.eclipse.equinox.p2.engine/profileRegistry/epp.package.modeling.profile/.data/.settings"
	UPDATE_SITE_METADATA="org.eclipse.equinox.p2.metadata.repository.prefs"
	UPDATE_SITE_ARTIFACT="org.eclipse.equinox.p2.artifact.repository.prefs"

	# First, create a ZIP as "backup"
	zip -q -r $UPDATE_SITE_CONFIG_PATH/update-sites.zip $UPDATE_SITE_CONFIG_PATH/$UPDATE_SITE_ARTIFACT $UPDATE_SITE_CONFIG_PATH/$UPDATE_SITE_METADATA

	rm -rf $UPDATE_SITE_CONFIG_PATH/$UPDATE_SITE_ARTIFACT 
	rm -rf $UPDATE_SITE_CONFIG_PATH/$UPDATE_SITE_METADATA
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
log "Clean-up Eclipse folder and extract downloaded archive."
rm -rf ./eclipse/*
if [[ "$OS" = "linux" ]]; then
	tar -xzf eclipse-modeling-$VERSION-R-linux-gtk-x86_64.tar.gz
elif [[ "$OS" = "windows" ]]; then
	unzip -qq -o eclipse-modeling-$VERSION-R-win32-x86_64.zip
elif [[ "$OS" = "macos" ]]; then
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

	# Check if additional packages must be skipped (for CI builds).
	if [[ "$p" = "additional" ]] && [[ $SKIP_THEME -eq 1 ]]; then
		log "Skipping additional plug-ins."
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

# Remove all configured update sites
remove_update_sites

# Deploy custom splash image
if [[ $SKIP_THEME -eq 1 ]]; then
	# Skip UI customization for CI builds
	log "Skipping custom splash image."
else
	log "Deploy custom splash image."
	chmod +x splash.sh && ./splash.sh deploy $VERSION $ECLIPSE_BASE_PATH
fi

log "Clean-up old archives and create new archive."
rm -f ./$OUTPUT_FILE
zip -q -r $OUTPUT_FILE eclipse

log "Build finished."
