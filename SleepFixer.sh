#!/bin/bash

send_notification () {
    local ICON="/usr/share/icons/Papirus/64x64/apps/system-shutdown.svg"
    if command -v "notify-send" &> /dev/null; then
        if [[ -f $ICON ]]; then
            notify-send -i "$ICON" "AutoSleep" "$*"
        else
            notify-send -i "" "AutoSleep" "$*"
        fi
    fi
}

TIME=$(date "+%H")
if [[ $TIME > 22 ]] && [[ $TIME < 5 ]]; then
    send_notification "Shutting Down in 30s";
    sleep 20;
    send_notification "Shutting Down in 10s";
    sleep 10;
    shutdown now;
else
    send_notification "Scheduled Shut Down at 23:00";
    shutdown -P 23:00
fi 

