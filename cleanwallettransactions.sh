#!/bin/bash
#
# @author webworker01

source /home/eclips/tools/coinlist
source /home/eclips/tools/config

dt=$(date '+%Y-%m-%d %H:%M:%S');

cleanerremoved=$($komodocli cleanwallettransactions | jq -r .removed_transactions)
if (( cleanerremoved > 0 )); then
    echo "$dt [cleanwallettransactions] KMD - Removed $cleanerremoved transactions"

if (( thirdpartycoins < 1 )); then
    for coins in "${coinlist[@]}"; do
        coin=($coins)
        if [[ ! ${ignoreacs[*]} =~ ${coin[0]} ]]; then
            echo ${coin[0]}
            cleanerremoved=$($komodocli -ac_name=${coin[0]} cleanwallettransactions | jq -r .removed_transactions)
            if (( cleanerremoved > 0 )); then
                echo "$dt [cleanwallettransactions] ${coin[0]} - Removed $cleanerremoved transactions"
            fi
        fi
    done
fi
