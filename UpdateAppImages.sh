#!/bin/bash

GITHUB_URL="https://github.com"

# Old Function which Scrapes Website for Ungoogled Chromium releases
# TODO: Make Another Script to Keep This
update_ungoogled_chromium_old() {
    # Downloading Ungoogled Chromium AppImage
    UNGOOGLED_SOFTWARE_URL="https://ungoogled-software.github.io"
    URL_PATH="/ungoogled-chromium-binaries/releases/appimage/64bit/"
    RELEASE_URL="$UNGOOGLED_SOFTWARE_URL$URL_PATH"
    RIP_GREP_QUERY="href=\"$URL_PATH.*\""

    URLS=$(curl -s $RELEASE_URL | rg -o $RIP_GREP_QUERY | choose -f '"' 1)
    echo "Downloading Latest Ungoogled Chromium AppImage"
    for URL in $URLS;
    do 
        echo "Scraping from $UNGOOGLED_SOFTWARE_URL$URL"
        # Get Download URL
        VERSION=$(echo -n "$URL" | choose -f '/' -1 | xargs)
        RIP_GREP_QUERY="ungoogled-chromium_${VERSION}"
        APP_IMAGE_URL=$(curl -s "$UNGOOGLED_SOFTWARE_URL$URL" | rg $RIP_GREP_QUERY | choose -f '"' 1)
        FILE_NAME=$(echo -n "$APP_IMAGE_URL" | choose -f '/' -1 | xargs)

        # Download File
        download_appimage $FILE_NAME $APP_IMAGE_URL
        # Making SymLink and Replacing Old File
        install_appimage $FILE_NAME
        exit
    done
}

download_appimage () {
    APPIMAGE_FILE=$(echo -n "$*" | choose -f '/' -1 | xargs)

    if [[ ! -d "$HOME/Apps/AppImage/" ]]; then
       mkdir -p "$HOME/Apps/AppImage/" 
    fi
    cd $HOME/Apps/AppImage/
    if [[ ! -f $APPIMAGE_FILE ]]; then
        echo "Downloading $APPIMAGE_FILE from $*"
        wget --quiet --show-progress $*
    else
        echo "Skipping Download as"
        echo "File:\"$APPIMAGE_FILE\" Already Exists"
    fi
}

determine_app_name () {
    local EXT;
    EXT=".AppImage"

    if [[ $* == "ungoogled-chromium"* ]]; then
        echo -n "ungoogled-chromium${EXT}" 
    elif [[ $* == "Logseq"* ]]; then
        echo -n "logseq${EXT}"
    elif [[ $APP_NAME_BY_USER != "NULL" ]]; then
        echo -n "${APP_NAME_BY_USER}${EXT}"
    else
        echo "NULL"
    fi
}

install_or_update_appimage () {
    local FILE_PATH;
    FILE_PATH="$HOME/Apps/AppImage/$*"
    if [[ -f $FILE_PATH ]]; then
        chmod +x $FILE_PATH
    else
        echo "File Hasn't Been Downloaded"
        echo "Exiting.."
        exit
    fi
    
    APP_NAME=$(determine_app_name $*)
    if [[ $APP_NAME != "NULL" ]]; then
        if [[ ! -d "$HOME/.local/bin/" ]]; then
            mkdir -p "$HOME/.local/bin/" 
        fi
        cd $HOME/.local/bin/

        if [[ -f $APP_NAME ]]; then
            if [[ $(readlink -f $APP_NAME) == $FILE_PATH ]]; then
                echo "File \"$APP_NAME\" Already Installed"
            else
                echo "SymLink \"$APP_NAME\" Already Exists, Making it Old"
                if [[ -f "${APP_NAME}.old" ]]; then
                    echo "Deleting Previous Old SymLink \"${APP_NAME}.old\""
                    rm "${APP_NAME}.old" 
                    echo "Deleting Previous File \"$(readlink -f $APP_NAME)\""
                    rm "$(readlink -f $APP_NAME)" 
                fi
                mv $APP_NAME "${APP_NAME}.old"
            fi
        fi
        echo "Creating SymLink as \"$APP_NAME\""
        ln -s "$HOME/Apps/AppImage/$*" $APP_NAME
        echo "Done, Thank You"
    else
        echo "Something Went Wrong, Check With Developer"
    fi
}

# TODO: Add This to Other Functions
check_url () {
    local RESPONSE;
    RESPONSE="NULL"
    if [[ $* == $GITHUB_URL* ]]; then
        if [[ $(curl -s -D - -o /dev/null $*| rg 'HTTP/2' | choose 1) -eq "200" ]]; then
            RESPONSE="200"
        fi
    fi

    echo $RESPONSE
}

get_latest_github_tag () {
    local LATEST_RELEASE_URL;
    local HEADERS;
    local LATEST_TAG_URL;

    HEADERS=$(curl -s -D - -o /dev/null "$*/releases/latest")
    if [[ $(echo -n "$HEADERS" | rg 'HTTP/2' | choose 1) -ne "302" ]]; then
        echo "NULL"
    else
        LATEST_TAG_URL=$(echo -n "$HEADERS" | rg 'location' | choose 1)
        echo "$(echo -n "$LATEST_TAG_URL" | choose -f '/' -1 | xargs)"
    fi
}

get_appimage_file_url () {
    local APPIMAGE_FILE_URL_PATH;
    APPIMAGE_FILE_URL_PATH=$(curl -s $* | rg '(.*href.*.AppImage.*)' | choose -f "\"" 1 | rg '.*AppImage.$')
    
    echo "${GITHUB_URL}${APPIMAGE_FILE_URL_PATH}"
}

# Installs/Updates AppImage File in System
install_or_update_app () {
    local GITHUB_REPO;
    local ASSET_PAGE;
    local APPIMAGE_URL;

    GITHUB_REPO="$*"
    echo "Installing/Updating App from Github Repo \"$GITHUB_REPO\""
    if [[ $(check_url $GITHUB_REPO) -ne "NULL" ]]; then
        LATEST_TAG=$(get_latest_github_tag $GITHUB_REPO)
        if [[ $LATEST_TAG != "NULL" ]]; then
            ASSET_PAGE="${GITHUB_REPO}/releases/expanded_assets/${LATEST_TAG}"
            APPIMAGE_URL=$(get_appimage_file_url $ASSET_PAGE)

            # Download File
            download_appimage $APPIMAGE_URL
            # Making SymLink and Replacing Old File
            install_or_update_appimage $APPIMAGE_FILE
        else
            echo "No Redirection"
        fi
    else
        echo "Github Repo Not Found, Check URL and Try Again!"
    fi
}

# App Functions
install_or_update_logseq () {
    echo "Installing/Updating Logseq"
    install_or_update_app "https://github.com/logseq/logseq"
}

install_or_update_ungoogled_chromium () {
    echo "Installing/Updating Ungoogled Chromium"
    install_or_update_app "https://github.com/clickot/ungoogled-chromium-binaries"
}

# All Apps Function
all_apps () {
    echo "Installing/Updating All Apps"
    # Logseq
    install_or_update_logseq
    # Ungoogled Chromium
    install_or_update_ungoogled_chromium

    echo "Thank You"
}

main () {
    APP_NAME_BY_USER="NULL"
    if [[ $1 == "all" ]]; then
        all_apps
    elif [[ $1 == "new" ]]; then
        # Usage
        # scriptname new "{app_name}" "{github_repo}"
        if [[ -z $2 ]]; then
            echo "App Name Not Provided, Exiting"
            exit
        fi
        APP_NAME_BY_USER=$2
        install_or_update_app $3
    elif [[ $1 == "--help" ]]; then
        echo -e "Usage: \n\t 'AppImageTool.sh all' for updating or installing existing apps"
        echo -e "\t 'AppImageTool.sh new {app_name} {github_repo}' for installing new app"
    else
        echo "Seek Help by using \"--help\""
    fi
}

main $*
