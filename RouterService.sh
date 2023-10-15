#!/bin/sh

DNS=$(uci get network.wan.dns)
QUAD9="9.9.9.9"         # Remote Hosted 1
AGDNS="94.140.14.15"    # Remote Hosted 2
MYDNS="192.168.1.116"   # Local Hosted

change_dns() {
    if [[ $DNS != $* ]]; then
        uci set network.wan.peerdns='0'
        uci del network.wan.dns
        uci add_list network.wan.dns=$*
        uci commit
        echo "Network Restart";
        /etc/init.d/network restart
        DNS=$*
    fi
}

reloadAndCommit() {
    echo "Reloading";
    fw3 reload &>/dev/null;
    echo "Commiting";
    uci commit;
}

# Checking And Changing DNS of Router
if [[ $DNS != $MYDNS ]]; then
    ping -c 1 $MYDNS &> /dev/null
    if [[ $? == 0 ]]; then
        echo "Changing DNS to MYDNS";
        change_dns "$MYDNS"
    else
        echo "DNS not changed as MYDNS is DOWN";
    fi
elif [[ $DNS == $MYDNS ]]; then
    ping -c 1 $MYDNS &> /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Changing DNS to AGDNS";
        change_dns "$AGDNS"
    else
        echo "DNS is already MYDNS";
    fi
fi

# Allowing Devices To Only Work With AdGuardHome
FirewallZoneRuleNumber=$(uci show firewall | grep "CutAcessWithoutAGH" | cut -d "[" -f 2 | cut -d "]" -f 1);
if [[ -z ${FirewallZoneRuleNumber} ]]; then
    echo "No Firewall Zone Rule named 'CutAcessWithoutAGH' Found. Exiting";
    exit;
fi

RuleStatus=$(echo -n "$(uci -q get firewall.@rule[$FirewallZoneRuleNumber].enabled)")
if [[ $DNS != $MYDNS ]]; then
    if [[ -z $RuleStatus ]] || [[ $RuleStatus == "1" ]]; then
        echo "Firewall Zone Rule 'CutAcessWithoutAGH' already Enabled";
    else
        echo "Enabling Firewall Zone Rule 'CutAcessWithoutAGH'";
        uci set firewall.@rule[$FirewallZoneRuleNumber].enabled=1;
        reloadAndCommit;
    fi
else
    if [[ -z $RuleStatus ]] || [[ $RuleStatus == "1" ]]; then
        echo "Disabling Firewall Zone Rule 'CutAcessWithoutAGH'";
        uci set firewall.@rule[$FirewallZoneRuleNumber].enabled=0;
        reloadAndCommit;
    else
        echo "Firewall Zone Rule 'CutAcessWithoutAGH' already Disabled";
    fi
fi
