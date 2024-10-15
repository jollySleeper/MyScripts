#!/bin/sh

for source in "github" "gitlab" "codeberg"
do
    echo "Creating Key for => $source"
    cd ~/.ssh
    ssh-keygen -t ed25519 -f "id_$source"
    echo "Public Key for => $source"
    bat "id_$source.pub"
    cd -
done
