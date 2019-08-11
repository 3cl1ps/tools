#!/bin/bash
#
# Script to join utxos into one without going over tx size limit
#
# Usage: consolidate <coinname>
#
# @author webworker01
#

source /home/eclips/tools/config
source /home/eclips/tools/functions

coin="KMD"
asset=""

unspent=$($komodocli $asset listunspent)
consolidateutxo=$(jq -r --arg checkaddr $KMDADDRESS '[.[] | select (.address==$checkaddr and .spendable==true)] | sort_by(-.amount)[0:399]' <<< $unspent)
consolidatethese=$(jq -r '[.[] | {"txid":.txid, "vout":.vout}] | tostring' <<< $consolidateutxo)
consolidateamount=$(jq -r '[.[].amount] | add' <<< $consolidateutxo)

if [[ "$consolidateamount" != "null" ]]; then
    consolidateamountfixed=$( printf "%.8f" $(bc -l <<< $consolidateamount) )

    if (( $(echo "$consolidateamountfixed > 0" | bc -l) )); then

        rawtxresult=$($komodocli $asset createrawtransaction ${consolidatethese} '''{ "'$KMDADDRESS'": '$consolidateamountfixed' }''')
        rawtxid=$(sendRaw ${rawtxresult} ${coin})

        echo "Sent $consolidateamount to $KMDADDRESS TXID: $rawtxid"
    fi
fi
