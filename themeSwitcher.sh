#!/bin/bash

# AutoTheme Switcher 
# Can be Used with Cron OR
# Night Theme Switcher Gnome Extension

ALACRITTY_PATH="$HOME/Dotfiles/alacritty/.config/alacritty/"
NVIM_THEME_PATH="$HOME/Dotfiles/neovim/.config/nvim/after/plugin/theme.lua"
BAT_CONFIG_FILE="$HOME/Dotfiles/bat/.config/bat/config"

if [[ "$*" == "light" ]]; then
    COLOR="$*"
    OPST_COLOR="dark"
    BAT_THEME="GitHub"
    BAT_THEME_TO_REPLACE="1337"
else
    COLOR="dark"
    OPST_COLOR="light"
    BAT_THEME="1337"
    BAT_THEME_TO_REPLACE="GitHub"
fi

# Alacritty
cd "$ALACRITTY_PATH"
rm colors.toml
ln -s "$COLOR.toml" colors.toml

# Nvim
sed -i "21s/$OPST_COLOR/$COLOR/g" $NVIM_THEME_PATH

# Bat
for line in $(rg "theme=" $BAT_CONFIG_FILE -n -m 1 | choose -f ":" 0)
do 
    sed -i "${line}s/${BAT_THEME_TO_REPLACE}/${BAT_THEME}/g" $BAT_CONFIG_FILE
done
