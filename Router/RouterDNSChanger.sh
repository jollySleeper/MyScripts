#!/bin/sh

DNS=$(uci get network.wan.dns)
QUAD9="9.9.9.9"         # Remote Hosted 1
AGDNS="94.140.14.15"    # Remote Hosted 2
MYDNS="192.168.1.105"   # Local Hosted

MYDNS_DASHBOARD="http://$MYDNS:8080"

change_dns() {
    if [[ $DNS != $* ]]; then
        uci set network.wan.peerdns='0'
        uci set network.wan6.peerdns='0'
        uci del network.wan.dns
        uci add_list network.wan.dns=$*
        uci commit
        echo "Restarting Network";
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
    pingCommandExitCode=$?

    # 'nc' Taking Too Long To Resolve as -z flag not available
    #res=$(nc "$MYDNS" 53)
    # 'nslookup' won't work as DNS is cached for some time
    #res=$(nslookup dns-server.lan | grep "Address 1")
    wget "$MYDNS_DASHBOARD" -O /tmp/status-check.html
    wgetCommandExitCode=$?

    echo "PING Exit Code = $pingCommandExitCode, WGET Exit Code = $wgetCommandExitCode"

    if [[ $pingCommandExitCode == 0 ]] && [[ $wgetCommandExitCode == 0 ]]; then
        echo "Changing DNS to MYDNS";
        change_dns "$MYDNS"
    else
        echo "DNS not changed as MYDNS is DOWN";
    fi
elif [[ $DNS == $MYDNS ]]; then
    ping -c 1 $MYDNS &> /dev/null
    pingCommandExitCode=$?

    # 'nc' Taking Too Long To Resolve as -z flag not available
    #res=$(nc 192.168.1.105 53)
    # 'nslookup' won't work as DNS is cached for some time
    #res=$(nslookup dns-server.lan | grep "Address 1")
    wget "$MYDNS_DASHBOARD" -O /tmp/status-check.html
    wgetCommandExitCode=$?

    echo "PING Exit Code = $pingCommandExitCode, WGET Exit Code = $wgetCommandExitCode"

    if [[ $pingCommandExitCode -ne 0 ]] || [[ $wgetCommandExitCode -ne 0 ]]; then
        echo "Changing DNS to AGDNS";
        change_dns "$AGDNS"
    else
        echo "DNS is already MYDNS";
    fi
fi

# Allowing Devices To Only Work With AdGuardHome
FirewallZoneRuleNumber=$(uci show firewall | grep "CutAcessWithoutAGH" | cut -d "[" -f 2 | cut -d "]" -f 1);
if [[ -z "$FirewallZoneRuleNumber" ]]; then
    echo "No Firewall Zone Rule named 'CutAcessWithoutAGH' Found. Exiting";
    exit;
fi

RuleStatus=$(echo -n "$(uci -q get firewall.@rule[${FirewallZoneRuleNumber}].enabled)")
if [[ $DNS != $MYDNS ]]; then
    if [[ -z "$RuleStatus" ]] || [[ "$RuleStatus" == "1" ]]; then
        echo "Firewall Zone Rule 'CutAcessWithoutAGH' already Enabled";
    else
        echo "Enabling Firewall Zone Rule 'CutAcessWithoutAGH'";
        uci set firewall.@rule[${FirewallZoneRuleNumber}].enabled=1;
        reloadAndCommit;
    fi
else
    if [[ -z "$RuleStatus" ]] || [[ "$RuleStatus" == "1" ]]; then
        echo "Disabling Firewall Zone Rule 'CutAcessWithoutAGH'";
        uci set firewall.@rule[${FirewallZoneRuleNumber}].enabled=0;
        reloadAndCommit;
    else
        echo "Firewall Zone Rule 'CutAcessWithoutAGH' already Disabled";
    fi
fi
