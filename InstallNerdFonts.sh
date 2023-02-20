#!/bin/bash

echo "Installing DejaVuSansMono & Hack Nerd Fonts & NotoColor Emoji Font"

if [[ ! -d "$HOME/.local/share/fonts" ]]; then
    echo "Making Directory '$HOME/.local/share/fonts'"
    mkdir -p "$HOME/.local/share/fonts" 
fi
cd "$HOME/.local/share/fonts" 

# NerFonts 
NERFONTS=("DejaVuSansMono" "Hack")
NERFONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download"
NERFONT_VERSION="v2.3.3"

for i in "${NERFONTS[@]}"
do
    if [[ ! -d "$i-NerdFont" ]]; then
        mkdir "$i-NerdFont"
    fi
    cd "$i-NerdFont"
    rm * 2> /dev/null || true
    echo "Downloading $i NerdFont of Version $NERFONT_VERSION"
    wget "$NERFONT_URL/$NERFONT_VERSION/$i.zip" -q --show-progress
    if [[ -f "$i.zip" ]]; then
        unzip -q "$i.zip"
        rm *Windows* *.txt *.md *.zip 2> /dev/null || true
    fi
    cd ..
done

# Emoji Font
if [[ ! -d "NotoColor-EmojiFont" ]]; then
    mkdir "NotoColor-EmojiFont"
fi
cd "NotoColor-EmojiFont"
rm * 2> /dev/null || true
echo "Downloading Noto Color Font for Emoji"
wget "https://fonts.google.com/download?family=Noto%20Color%20Emoji" -O "NotoColorEmoji.zip" -q --show-progress
if [[ -f "NotoColorEmoji.zip" ]]; then
    unzip -q "NotoColorEmoji.zip"
    rm *Windows* *.txt *.md *.zip 2> /dev/null || true
fi
cd ..

fc-cache -f
echo "Done :P"
