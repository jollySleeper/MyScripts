#!/bin/bash

if [[ -z $1 ]] && [[ -z $2 ]]; then
    echo "Please Enter High and Low Quality Folders"
fi

highFolder=$1
lowFolder=$2

#highFold=$(echo "$highFolder" | cut -d "_HQ" -f 1)
#lowFold=$(echo "$lowFolder" | cut -d "_LQ" -f 1)
#if [[ $highFold == $lowFold ]]; then
#    outputFolder=$highFold
#    echo "$outputFolder"
#    exit
#fi

outputFolder="Season_02"

for fileWithFolderName in $lowFolder/*; do
    
    file=$(echo $fileWithFolderName | cut -d "/" -f 2)
    if [[ "$file" != *".mkv" ]]; then
	continue
    fi
    
    if [[ -f "$outputFolder/$file" ]]; then
        echo -e "File '$outputFolder/$file' Already Made/Exists \n"
	continue
    fi

    episode=$(echo "$file" | cut -d "_" -f 2)
    highFile=$(ls "$highFolder" | grep "$episode" | grep ".mkv$")
    if [[ -f "$highFolder/$highFile" ]]; then
        
        if [[ ! -f "$highFolder/$file-audio.mka" ]]; then
            echo "Making High Resolution Audio '$highFolder/$file-audio.mka'"
            mkvmerge -D -S -B -M --no-global-tags --no-chapters \
                -q -o "$highFolder/$file-audio.mka" "$highFolder/$highFile"
        else
            echo "Getting High Resolution Audio '$highFolder/$file-audio.mka'"
        fi
        
        echo "Making Remuxed File '$outputFolder/$file'"
        title=$(echo "$file" | cut -d "\`" -f 2 | sed 's/_/ /g')

	audioTrackCount=$(mkvmerge -i "$fileWithFolderName" | grep -c "audio")
        if [[ $audioTrackCount -lt 2 ]]; then
            mkvmerge -q -o "$outputFolder/$file" \
                --no-audio --track-name "0:1080p H.265" "$lowFolder/$file" \
                --language 0:eng --track-name "0:DD+ 5.1" "$highFolder/$file-audio.mka" --track-order 0:0,1:0 \
		--title "$title"
	elif [[ $audioTrackCount -lt 3 ]]; then
            mkvmerge -q -o "$outputFolder/$file" \
                --no-audio --track-name "0:1080p H.265" "$lowFolder/$file" \
                --language 0:eng --track-name "0:DD+ 5.1" --language 1:eng \
		--track-name "1:Commentary" "$highFolder/$file-audio.mka" --track-order 0:0,1:0,1:1 \
		--title "$title"
        fi
        echo -e "Done \n"
    else
        echo -e "File '$file' doesn't exists in Folder '$highFolder' \n"
    fi
done
