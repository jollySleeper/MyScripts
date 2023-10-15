#!/bin/bash

# cat NestFireWallZoneAutomation.sh | ssh root@router.lan sh 

# Having Firewall Zone as "Nest"
FirewallZoneRuleNumber=$(uci show firewall | grep "Nest" | cut -d "[" -f 2 | cut -d "]" -f 1);
if [[ -z ${FirewallZoneRuleNumber} ]]; then
    echo "No Firewall Zone Rule named 'Nest' Found. Exiting";
    exit;
fi

reloadAndCommit() {
    echo "Reloading";
    fw3 reload &>/dev/null;
    echo "Commiting";
    uci commit;
}

RuleStatus=$(echo -n "$(uci -q get firewall.@rule[$FirewallZoneRuleNumber].enabled)")
if [[ -z $RuleStatus ]] || [[ $RuleStatus == "1" ]]; then
    echo "Disabling Firewall Zone Rule 'Nest'";
    uci set firewall.@rule[$FirewallZoneRuleNumber].enabled=0;
    reloadAndCommit;

    echo "Sleeping for 15s"
    sleep 15;

    echo "Enabling Firewall Zone Rule 'Nest'";
    uci set firewall.@rule[$FirewallZoneRuleNumber].enabled=1;
    reloadAndCommit;
else
    echo "Firewall Zone Rule 'Nest' already Disabled";
fi
