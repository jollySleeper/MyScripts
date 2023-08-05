#!/bin/bash

# Cloning My Git Repos And Syncing it to GitLab, GitHub & CodeBerg

# Local Variables
USER=jollySleeper
EMAIL=git@pm21.anonaddy.com
GITHUB_URL="https://github.com"
GITHUB_SSH_ALIAS=github.com
GITLAB_SSH_ALIAS=gitlab.com
CODEBERG_SSH_ALIAS=codeberg.org

check_url () {
    local RESPONSE;
    RESPONSE="NULL"

    if [[ ! -z $* ]]; then
        # Hitting URL for Getting Response Code
        if [[ $(curl -s -D - -o /dev/null $URL | rg 'HTTP/2' | choose 1) -eq "200" ]]; then
            RESPONSE="200"
        fi
    fi

    echo $RESPONSE
}

# Checking if URL Provided
if [[ -z $1 ]]; then
    echo "URL Not Provided, Please Try Again!"
    exit
fi

# Creating URL
if [[ $1 == *".git" ]]; then
    URL="$(echo -n "$1" | choose -f ".git$" 0)"
fi

# Check if Using SSH for Cloning
if [[ $1 == *"@"* ]]; then
    URL="${GITHUB_URL}/$(echo -n "$1" | choose -f ":" 1)"
else
    URL=$1
fi

# Check if URL Provided is Valid
if [[ $(check_url $URL) -eq "NULL" ]]; then
    echo "URL Provided isn't Valid"
    exit
fi

# Generating Folder Name from URL
REPO=$(echo -n $URL | choose -f "/" -1)

if [[ -z $2 ]]; then
    echo "Custom Folder Name Not Provided, Using Default"
    FOLDER_TO_CLONE_IN=$REPO
else
    FOLDER_TO_CLONE_IN=$2
fi

# Clone Repo
# In Case SSH URL Provided
git clone $1 $FOLDER_TO_CLONE_IN

# Creating Directory
cd $FOLDER_TO_CLONE_IN

# Git
git config --local user.name $USER
git config --local user.email $EMAIL

# Adding Origin
# Make sure repo is created with same name on Github
git remote remove origin
git remote add origin "git@${GITHUB_SSH_ALIAS}:${USER}/${REPO}.git"

# Setting Origin Push Urls
git remote set-url --add --push origin "git@${GITHUB_SSH_ALIAS}:${USER}/${REPO}.git"
git remote set-url --add --push origin "git@${GITLAB_SSH_ALIAS}:${USER}/${REPO}.git"
git remote set-url --add --push origin "git@${CODEBERG_SSH_ALIAS}:${USER}/${REPO}.git"

echo "Done! Thank You <3"
