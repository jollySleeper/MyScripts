#!/bin/bash

if [[ -z $1 ]] && [[ -z $2 ]]; then
    echo "Please Enter High and Low Quality File"
    exit 1
fi

hqFile=$1
lqFile=$2

if [[ ! -f "$lqFile" ]] && [[ ! -f "$hqFile" ]]; then
    echo "Files do not exist"
    exit 1 
fi

if [[ "$lqFile" != *".mkv" ]] && [[ "$hqFile" != *".mkv" ]]; then
    echo "Not MKV File"
    exit 1 
fi

# OUTPUT-File
title=$(echo "$lqFile" | cut -d "\`" -f 1 | sed 's/_/ /g')
outFile=$(echo "$title.mkv" | sed 's/ /_/g')
if [[ -f "$lqFile" ]]; then
    echo -e "File '$outFile' Already Made/Exists \n"
    exit 0
fi

    
if [[ ! -f "$hqFile-audio.mka" ]]; then
    echo "Making High Resolution Audio '$hqFile-audio.mka'"
    mkvmerge -D -S -B -M --no-global-tags --no-chapters \
        -q -o "$hqFile-audio.mka" "$hqFile"
else
    echo "Getting High Resolution Audio '$hqFile-audio.mka'"
fi
    
echo "Making Remuxed File '$outFile'"

audioTrackCount=$(mkvmerge -i "$hqFile" | grep -c "audio")
if [[ $audioTrackCount -lt 2 ]]; then
    mkvmerge -q -o "$outFile" \
        --no-audio --track-name "0:1080p H.265" "$lqFile" \
        --language 0:eng --track-name "0:DD+ 5.1" "$hqFile-audio.mka" --track-order 0:0,1:0 \
        --title "$title"
fi
echo -e "Done \n"
