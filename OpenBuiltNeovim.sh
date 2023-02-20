#!/bin/bash

DIR=$(pwd)
BUILD_LOCATION=$HOME/neovim-stable

if [[ $* == "" ]]; then
    ARGS=""
elif [[ $* == "." ]]; then
    ARGS=$DIR   
else
    ARGS=$DIR
    ARGS+="/"
    ARGS+=$*
fi

cd $BUILD_LOCATION
VIMRUNTIME=runtime ./build/bin/nvim "$ARGS"

#Go Back to Directory
cd $DIR
