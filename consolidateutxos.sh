#!/bin/bash
#
# Script to join utxos into one without going over tx size limit
#
# Usage: consolidate <coinname>
#
# @author webworker01
#

source /home/eclips/tools/main

coin="KMD"
asset=""

unspent=$(komodo-cli $asset listunspent)
consolidateutxo=$(jq -r --arg checkaddr $nn_address '[.[] | select (.address==$checkaddr and .spendable==true)] | sort_by(-.amount)[0:399]' <<< $unspent)
consolidatethese=$(jq -r '[.[] | {"txid":.txid, "vout":.vout}] | tostring' <<< $consolidateutxo)
consolidateamount=$(jq -r '[.[].amount] | add' <<< $consolidateutxo)

if [[ "$consolidateamount" != "null" ]]; then
    consolidateamountfixed=$( printf "%.8f" $(bc -l <<< $consolidateamount) )

    if (( $(echo "$consolidateamountfixed > 0" | bc -l) )); then

        rawtxresult=$(komodo-cli $asset createrawtransaction ${consolidatethese} '''{ "'$nn_address'": '$consolidateamountfixed' }''')
        rawtxid=$(sendRaw ${rawtxresult} ${coin})

        echo "Sent $consolidateamount to $nn_address TXID: $rawtxid"
    fi
fi
