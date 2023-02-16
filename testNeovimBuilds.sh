#!/bin/bash

# Downloading Release
wget https://github.com/neovim/neovim/archive/refs/tags/stable.tar.gz
tar -xf stable.tar.gz
mv neovim-stable neovim
cd neovim

# Calculating Duration
SECONDS=0
make CMAKE_BUILD_TYPE=Release

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."
