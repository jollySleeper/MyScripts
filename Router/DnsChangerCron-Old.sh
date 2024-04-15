#!/bin/sh

DNS=$(uci get network.wan.dns)
QUAD9="9.9.9.9"
AGH="192.168.1.116"

change_dns() {
    if [[ $DNS != $* ]]; then
        uci set network.wan.peerdns='0'
        uci del network.wan.dns
        uci add_list network.wan.dns=$*
        uci commit
        echo "Network Restart";
        /etc/init.d/network restart
    fi
}

if [[ $DNS != $AGH ]]; then
    ping -c 1 $AGH &> /dev/null
    if [[ $? == 0 ]]; then
        echo "Changing DNS to AGH";
        change_dns "$AGH"
    else
        echo "DNS not changed as AGH is DOWN";
    fi
elif [[ $DNS == $AGH ]]; then
    ping -c 1 $AGH &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Changing DNS to QUAD9";
        change_dns "$QUAD9"
    else
        echo "DNS is already AGH";
    fi
fi

