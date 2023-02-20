#!/bin/bash

# Initializing Git Repo And Syncing it to GitLab & Github Both

# Local Variables
USER=jollySleeper
EMAIL=git@pm21.anonaddy.com
GITHUB_SSH_ALIAS=github.com
GITLAB_SSH_ALIAS=gitlab.com
CODEBERG_SSH_ALIAS=codeberg.org

# Creating Directory
mkdir $*
cd $*

# Git
git init --initial-branch main
git config --local user.name $USER
git config --local user.email $EMAIL

# Making First Commit
echo -e "\n--- \t Commiting \t ---\n"
echo "# $* Initialized" >> README.md
git add .
git commit -m "Initial Commit"

# Adding Origin
# Make sure repo is created with same name on Github
git remote add origin git@$GITHUB_SSH_ALIAS:$USER/$*.git

# Setting Origin Push Urls
git remote set-url --add --push origin git@$GITHUB_SSH_ALIAS:$USER/$*.git 
git remote set-url --add --push origin git@$GITLAB_SSH_ALIAS:$USER/$*.git 
git remote set-url --add --push origin git@$CODEBERG_SSH_ALIAS:$USER/$*.git 

# Pushing
echo -e "\n--- \t Pushing \t ---\n"
git push --set-upstream origin main
