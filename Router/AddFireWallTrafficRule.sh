#!/bin/sh

# cat AddFireWallTrafficRule.sh | ssh root@router.lan|router sh 

reloadAndCommit() {
    echo "Reloading";
    fw3 reload &>/dev/null;
    echo "Commiting";
    uci commit;
}

# Getting Highest FireWall Rule Index
getMaxFirewallRuleIndex() {
    MaxFirewallRuleIndex=$(uci show firewall | grep -o "rule\[[0-9]*\]\=rule" | cut -d "[" -f 2 | cut -d "]" -f 1 | sort -nr | head -n 1);
    if [[ -z ${MaxFirewallRuleIndex} ]]; then
        echo "Highest Firewall Rule Not Found. Exiting";
        exit 1;
    fi
    echo "Found Highest Firewall Rule Index = $MaxFirewallRuleIndex"
}

getNewFirewallRuleIndex() {
    getMaxFirewallRuleIndex
    NewFirewallRuleIndex=$(($MaxFirewallRuleIndex+1))
    echo "Using New Firewall Rule Index = $NewFirewallRuleIndex"
}

echo "Adding Firewall Traffic Rule"
getNewFirewallRuleIndex
uci add firewall rule
# Name For FireWall Rule
uci set firewall.@rule[$NewFirewallRuleIndex].name="BlockNest"
# Source from Where the Device is to Blocked
uci set firewall.@rule[$NewFirewallRuleIndex].src="lan"
# Source IP Address
uci set firewall.@rule[$NewFirewallRuleIndex].src_ip="192.168.1.201"
# Block Internet
uci set firewall.@rule[$NewFirewallRuleIndex].dest="wan"
# DROP vs REJECT
uci set firewall.@rule[$NewFirewallRuleIndex].target="REJECT"
reloadAndCommit

sleep 3

echo "Adding Firewall Traffic Rule"
getNewFirewallRuleIndex
uci add firewall rule
# Name For FireWall Rule
uci set firewall.@rule[$NewFirewallRuleIndex].name="CutAcessWithoutAGH"
# Source from Where the Device is to Blocked
uci set firewall.@rule[$NewFirewallRuleIndex].src="lan"
# Source IP Address
uci set firewall.@rule[$NewFirewallRuleIndex].src_ip="192.168.1.111"
# Block Internet
uci set firewall.@rule[$NewFirewallRuleIndex].dest="wan"
# DROP vs REJECT
uci set firewall.@rule[$NewFirewallRuleIndex].target="REJECT"
reloadAndCommit
