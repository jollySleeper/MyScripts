#!/bin/bash

# Initializing Git Repo And Syncing it to GitLab, GitHub & CodeBerg

# Local Variables
USER=jollySleeper
EMAIL=git@pm21.anonaddy.com
GITHUB_SSH_ALIAS=github.com
GITLAB_SSH_ALIAS=gitlab.com
CODEBERG_SSH_ALIAS=codeberg.org

if [[ -z $* ]]; then
    echo "Folder Name Not Provided, Exiting"
    exit
fi

REPO=$*
# Creating Directory
mkdir -p $REPO
cd $REPO

# Git
git init --initial-branch main
git config --local user.name $USER
git config --local user.email $EMAIL

# Making First Commit
echo -e "\n--- \t Commiting \t ---\n"
echo "# $REPO Initialized" >> README.md
git add .
git commit -m "Repo Initialized"

# Adding Origin
# Make sure repo is created with same name on Github
git remote add origin "git@${GITHUB_SSH_ALIAS}:${USER}/${REPO}.git"

# Setting Origin Push Urls
git remote set-url --add --push origin "git@${GITHUB_SSH_ALIAS}:${USER}/${REPO}.git"
git remote set-url --add --push origin "git@${GITLAB_SSH_ALIAS}:${USER}/${REPO}.git"
git remote set-url --add --push origin "git@${CODEBERG_SSH_ALIAS}:${USER}/${REPO}.git"

# Pushing
echo -e "\n--- \t Pushing \t ---\n"
git push --set-upstream origin main
