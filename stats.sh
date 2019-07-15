#!/bin/bash
# Stats script for Komodo Notary Nodes
#
# @author webworker01
#
source coinlist
source config
source functions
source paths

color_red=$'\033[0;31m'
color_reset=$'\033[0m'

checkRepo () {
    if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
        return
    fi

    prevdir=${PWD}

    #eval cd "$2"
    cd $2

    git remote update > /dev/null 2>&1

    localrev=$(git rev-parse HEAD)
    remoterev=$(git rev-parse $3)
    cd $prevdir

    if [ $localrev != $remoterev ]; then
        printf "$color_red[U]$color_reset"
    fi

    case $1 in
        KMD|GIN)
            printf "     "
            ;;
        CHIPS)
            printf "   "
            ;;
        GAME|EMC2)
            printf "    "
            ;;
    esac
}

#Do not change below for any reason!
#The BTC and KMD address here must remain the same. Do not need to enter yours!

utxoamt=0.00010000
ntrzdamt=-0.00083600
btcntrzaddr=1P3rU1Nk1pmc2BiWC8dEy9bZa1ZbMp5jfg
kmdntrzaddr=RXL3YXG2ceaB6C5hfJcN4fvmLH2C34knhA
#Only count KMD->BTC after this timestamp (block 814000)
timefilter=1525032458
#Second time filter for assetchains (SuperNET commit 07515fb)
timefilter2=1525513998

format="%-11s %6s %7s %6s %.20s %8s %7s %5s %6s %6s"

outputstats ()
{
    count=0
    totalntrzd=0
    now=$(date +"%H:%M")

    printf "\n\n"
    printf "%-11s %6s %7s %6s %8s %8s %7s %5s %6s\n" "-CHAIN-" "-NOTR-" "-LASTN-" "-UTXO-" "-BAL-" "-BLOX-" "-LASTB-" "-CON-" "-SIZE-";

    kmdinfo=$(komodo-cli getinfo)
    kmdtxinfo=$(komodo-cli listtransactions "" $txscanamount)
    kmdlastntrztime=$(echo $kmdtxinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
    kmdutxos=$(komodo-cli listunspent | jq --arg amt "$utxoamt" '[.[] | select(.amount==($amt|tonumber))] | length')
    repo=(${repos[KMD]})
    printf "$format\n" "KMD$(checkRepo KMD ${repo[0]} ${repo[1]})" \
            "" \
            "$(timeSince $kmdlastntrztime)" \
            "$kmdutxos" \
            "$(printf "%8.3f" $(echo $kmdinfo | jq .balance))" \
            "$(echo $kmdinfo | jq .blocks)" \
            "$(timeSince $(komodo-cli getblock $(komodo-cli getbestblockhash) | jq .time))" \
            "$(echo $kmdinfo | jq .connections)" \
            "$(ls -lh ~/.komodo/wallet.dat  | awk '{print $5}')" \
            "$(echo $kmdtxinfo | jq '[.[] | select(.generated==true)] | length') mined"

    declare -a othercoins=()
    if (( thirdpartycoins < 1 )); then
        for i in ${!coinsfirst[@]}; do
            othercoins[$i]="${coinsfirst[$i]}"
        done
    else
        for i in ${!coinsthird[@]}; do
            othercoins[$i]="${coinsthird[$i]}"
        done
    fi

    for coins in "${othercoins[@]}"; do
        coin=($coins)

        case ${coin[0]} in
            BTC)
                coinsutxoamount=$utxoamt
                coinsntraddr=$btcntrzaddr
                ;;
            GAME)
                coinsutxoamount=0.00100000
                coinsntraddr=Gftmt8hgzgNu6f1o85HMPuwTVBMSV2TYSt
                ;;
            GIN)
                coinsutxoamount=$utxoamt
                coinsntraddr=Gftmt8hgzgNu6f1o85HMPuwTVBMSV2TYSt
                ;;
            HUSH)
                coinsutxoamount=$utxoamt
                coinsntraddr=t1fvTULnsz9ZCcpmQ8ZSN6xhUpfkgEuqeNX
                ;;
            EMC2)
                coinsutxoamount=0.00100000
                coinsntraddr=EfCkxbDFSn4X1VKMzyckyHaXLf4ithTGoM
                ;;
            *)
                coinsutxoamount=$utxoamt
                coinsntraddr=$kmdntrzaddr
                ;;
        esac

        #expand coinexec
        eval $(echo coinexec=${coin[1]})

        coinstxinfo=$($coinexec listtransactions "" $txscanamount)
        coinslastntrztime=$(echo $coinstxinfo | jq -r --arg address "$coinsntraddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
        coinsntrzd=$(echo $coinstxinfo | jq --arg address "$coinsntraddr" --arg timefilter $timefilter2 '[.[] | select(.time>=($timefilter|tonumber) and .address==$address and .category=="send")] | length')
        otherutxo=$($coinexec listunspent | jq --arg amt "$coinsutxoamount" '[.[] | select(.amount==($amt|tonumber))] | length')
        totalntrzd=$(( $totalntrzd + $coinsntrzd ))
        repo=(${repos[${coin[0]}]})
        balance=$($coinexec getbalance)
        if (( $(bc <<< "$balance < 0.02") )); then
            balance="${color_red}$(printf "%8.3f" $balance)${color_reset}"
        else
            balance=$(printf "%8.3f" $balance)
        fi
        printf "$format\n" "${coin[0]}$(checkRepo ${coin[0]} ${repo[0]} ${repo[1]})" \
                "$coinsntrzd" \
                "$(timeSince $coinslastntrztime)" \
                "$otherutxo" \
                "$balance" \
                "$($coinexec getblockchaininfo | jq .blocks)" \
                "$(timeSince $($coinexec getblock $($coinexec getbestblockhash) | jq .time))" \
                "$($coinexec getnetworkinfo | jq .connections)" \
                "$(ls -lh ~/${coin[3]}/wallet.dat | awk '{print $5}')"
    done

    if (( thirdpartycoins < 1 )); then
        lastcoin=(${coinlist[-1]})
        secondlast=(${coinlist[-2]})
        for coins in "${coinlist[@]}"; do
            coin=($coins)

            if [[ ! ${ignoreacs[*]} =~ ${coin[0]} ]]; then
                info=$(komodo-cli -ac_name=${coin[0]} getinfo)
                mininginfo=$(komodo-cli -ac_name=${coin[0]} getmininginfo)
                txinfo=$(komodo-cli -ac_name=${coin[0]} listtransactions "" $txscanamount)
                lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
                acntrzd=$(echo $txinfo | jq --arg address "$kmdntrzaddr" --arg timefilter $timefilter2 '[.[] | select(.time>=($timefilter|tonumber) and .address==$address and .category=="send")] | length')
                totalntrzd=$(( $totalntrzd + $acntrzd ))
                acutxo=$(komodo-cli -ac_name=${coin[0]} listunspent | jq --arg amt "$utxoamt" '[.[] | select(.amount==($amt|tonumber))] | length')
                repo=(${repos[${coin[0]}]})
                balance=$(jq .balance <<< $info)
                if (( $(bc <<< "$balance < 0.02") )); then
                    balance="${color_red}$(printf "%8.3f" $balance)${color_reset}"
                else
                    balance=$(printf "%8.3f" $balance)
                fi
                laststring=""

                if [[ ${coin[0]} == ${lastcoin[0]} ]]; then
                    laststring="@ $now"
                fi
                if [[ ${coin[0]} == ${secondlast[0]} ]]; then
                    laststring="All:$totalntrzd"
                fi

                printf "$format" "${coin[0]}$(checkRepo ${coin[0]} ${repo[0]} ${repo[1]})" \
                        "$acntrzd" \
                        "$(timeSince $lastntrztime)" \
                        "$acutxo" \
                        "$balance" \
                        "$(echo $info | jq .blocks)" \
                        "$(timeSince $(komodo-cli -ac_name=${coin[0]} getblock $(komodo-cli -ac_name=${coin[0]} getbestblockhash) | jq .time))" \
                        "$(echo $info | jq .connections)" \
                        "$(ls -lh ~/.komodo/${coin[0]}/wallet.dat  | awk '{print $5}')" \
                        "$laststring"

                if [[ ${coin[0]} != ${lastcoin[0]} ]]; then
                    echo
                fi
            fi
        done
    fi
}

if [ "$sleepytime" != "false" ]; then
    while true; do
        outputstats
        sleep $sleepytime
    done
else
    outputstats
    echo
fi
