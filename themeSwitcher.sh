#!/bin/bash

# AutoTheme Switcher 
# Can be Used with Cron OR
# Night Theme Switcher Gnome Extension

ALACRITTY_PATH="$HOME/Dotfiles/alacritty/.config/alacritty/"
NVIM_THEME_PATH="$HOME/Dotfiles/neovim/.config/nvim/after/plugin/theme.lua"

if [[ "$*" == "light" ]]; then
    COLOR="$*"
    OPST_COLOR="dark"
else
    COLOR="dark"
    OPST_COLOR="light"
fi

# Alacritty
cd "$ALACRITTY_PATH"
rm colors.toml
ln -s "$COLOR.toml" colors.toml

# Nvim
sed -i "21s/$OPST_COLOR/$COLOR/g" $NVIM_THEME_PATH
