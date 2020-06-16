#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Optionally just split UTXOs for a single coin
# e.g "KMD"
coin=$1

kmd_target_utxo_count=50
kmd_split_threshold=20

btc_split_threshold=20

other_target_utxo_count=30
other_split_threshold=10

date=$(date +%Y-%m-%d:%H:%M:%S)

calc() {
    awk "BEGIN { print "$*" }"
}

if [[ -z "${coin}" ]]; then
    /home/eclips/tools/listcoins.sh | while read coin; do
    /home/eclips/tools/utxosplitter.sh $coin &
done;
exit;
fi

cli=$(./listclis.sh ${coin})
if [[ "${coin}" = "KMD" ]]; then
    target_utxo_count=$kmd_target_utxo_count
    split_threshold=$kmd_split_threshold
elif [[ "${coin}" = "BTC" ]]; then
    split_threshold=$btc_split_threshold
else
    target_utxo_count=$other_target_utxo_count
    split_threshold=$other_split_threshold
fi

#satoshis=10000
#amount=$(calc $satoshis/100000000)
unlocked_utxos=$(${cli} listunspent | jq -r '.[].amount' | grep .00010000 | wc -l) 
locked_utxos=$(${cli} listlockunspent | jq -r length)
utxo_count=$(calc ${unlocked_utxos}+${locked_utxos})

echo $coin $utxo_count :: $unlocked_utxos :: $locked_utxos ::: $split_threshold
if [[ ${utxo_count} -le ${split_threshold} ]]; then
    if [[ "${coin}" = "BTC" ]]; then
#        /home/eclips/tools/btcsplit.sh
        exit
    fi
    utxo_required=$(calc ${target_utxo_count}-${utxo_count})
    echo "[${coin}] Splitting ${utxo_required} extra UTXOs"
    json=$(/home/eclips/tools/acsplit ${coin} ${utxo_required})
    txid=$(echo ${json} | jq -r '.txid')
    if [[ ${txid} != "null" ]]; then
        echo "[${coin}] Split TXID: ${txid}"
    else
        echo "[${coin}] Error: $(echo ${json} | jq -r '.error')"
    fi
fi
