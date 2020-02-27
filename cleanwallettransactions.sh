#!/bin/bash
#
# @author webworker01

source /home/eclips/tools/main

dt=$(date '+%Y-%m-%d %H:%M:%S');

cleanerremoved=$(komodo-cli cleanwallettransactions | jq -r .removed_transactions)
if (( cleanerremoved > 0 )); then
    echo "$dt [cleanwallettransactions] KMD - Removed $cleanerremoved transactions"
fi

/home/eclips/komodo/src/listassetchains | while read coin; do
    if [[ ! ${ignoreacs[*]} =~ ${coin[0]} ]]; then
        #echo ${coin[0]}
        cleanerremoved=$(komodo-cli -ac_name=${coin[0]} cleanwallettransactions | jq -r .removed_transactions)
        if (( cleanerremoved > 0 )); then
            echo "$dt [cleanwallettransactions] ${coin[0]} - Removed $cleanerremoved transactions"
        fi
    fi
done
