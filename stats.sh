#!/bin/bash
# Stats script for Komodo Notary Nodes
#
# by webworker01
#
# Requires jq v1.5+, bc - sudo apt-get install jq bc
#
# komodo-cli, bitcoin-cli, chips-cli and gamecredits-cli installed (e.g. symlinked to /usr/local/bin)

#==Options - Only Change These==

#Seconds in display loop, change to false if you don't want it to loop
sleepytime=600

#How many transactions back to scan for notarizations
txscanamount=777

#You can modify this list of ACs to exclude or comment out the line to show all
ignoreacs=('VOTE2018' 'BEER' 'PIZZA' 'VOTE2019')

#Full path to komodo-cli
komodoexec=/usr/local/bin/komodo-cli

#git checking - path and remote branch
declare -A repos=(
[KMD]='$HOME/komodo origin/beta'
[SUPERNET]='$HOME/SuperNET origin/dev'
[CHIPS]='$HOME/chips3 origin/dev'
[GAME]='$HOME/game origin/master'
[EMC2]='$HOME/einsteinium origin/master'
[GIN]='$HOME/gincoin origin/master'
)

#declare non komodo clis - symlink them to /usr/local/bin or set the full path accessible as the second part of each string
othercoins=(
'BTC bitcoin-cli'
'CHIPS chips-cli'
'GAME gamecredits-cli'
'EMC2 einsteinium-cli'
'GIN gincoin-cli'
)

#==End Options==

color_red=$'\033[0;31m'
color_reset=$'\033[0m'

timeSince () {
    local currentimestamp=$(date +%s)
    local timecompare=$1

    if [ ! -z $timecompare ] && [[ $timecompare != "null" ]]
    then
        local t=$((currentimestamp-timecompare))

        local d=$((t/60/60/24))
        local h=$((t/60/60%24))
        local m=$((t/60%60))
        local s=$((t%60))

        if (( d > 0 )); then
            echo -n "${d}D"
        fi
        if (( d < 2 && h > 0 )); then
            echo -n "${h}h"
        fi
        if (( d == 0 && h < 4 && m > 0 )); then
            echo -n "${m}m"
        fi
        if (( d == 0 && h == 0 && m == 0 )); then
            echo -n "${s}s"
        fi

    fi
}

checkRepo () {
    if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
        return
    fi

    prevdir=${PWD}

    eval cd "$2"

    git remote update > /dev/null 2>&1

    localrev=$(git rev-parse HEAD)
    remoterev=$(git rev-parse $3)
    cd $prevdir

    if [ $localrev != $remoterev ]; then
        printf "$color_red[U]$color_reset"
    fi

    case $1 in
        KMD)
            printf "     "
            ;;
        CHIPS)
            printf "   "
            ;;
        GAME)
            printf "    "
            ;;
        EMC2)
            printf "    "
            ;;
    esac
}

#Do not change below for any reason!
#The BTC and KMD address here must remain the same. Do not need to enter yours!
coinlist=(
'AXO 200000000'
'BET 999999'
'BOTS 999999'
'BTCH 20998641'
'BNTN 500000000'
'CCL 200000000'
'CEAL 366666666'
'CHAIN 999999'
'COQUI 72000000'
'CRYPTO 999999'
'DEX 999999'
'DION 3900000000'
'DSEC 7000000'
'ETOMIC 100000000'
'EQL 500000000'
'GLXT 10000000000'
'HODL 9999999'
'JUMBLR 999999'
'KMDICE 10500000'
'KSB 1000000000'
'KV 1000000'
'MESH 1000007'
'MGW 999999'
'MNZ 257142858'
'MSHARK 1400000'
'NINJA 100000000' 
'OOT 216000000'
'OUR 100000000'
'PANGEA 999999'
'PGT 10000000'
'PIRATE 0'
'PRLPAY 500000000'
'REVS 1300000'
'RFOX 1000000000'
'SEC 1000000000'
'SUPERNET 816061'
'VRSC 0'
'HUSH3 0'
'WLC 210000000'
'ZILLA 11000000'
'ZEXO 0'
'K64 0'

)
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

    kmdinfo=$($komodoexec getinfo)
    kmdtxinfo=$($komodoexec listtransactions "" $txscanamount)
    kmdlastntrztime=$(echo $kmdtxinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
    kmdutxos=$($komodoexec listunspent | jq --arg amt "$utxoamt" '[.[] | select(.amount==($amt|tonumber))] | length')
    repo=(${repos[KMD]})
    printf "$format\n" "KMD$(checkRepo KMD ${repo[0]} ${repo[1]})" \
            "" \
            "$(timeSince $kmdlastntrztime)" \
            "$kmdutxos" \
            "$(printf "%8.3f" $(echo $kmdinfo | jq .balance))" \
            "$(echo $kmdinfo | jq .blocks)" \
            "$(timeSince $($komodoexec getblock $($komodoexec getbestblockhash) | jq .time))" \
            "$(echo $kmdinfo | jq .connections)" \
            "$(ls -lh ~/.komodo/wallet.dat  | awk '{print $5}')" \
            "$(echo $kmdtxinfo | jq '[.[] | select(.generated==true)] | length') mined"

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
            EMC2)
                coinsutxoamount=0.00100000
                coinsntraddr=EfCkxbDFSn4X1VKMzyckyHaXLf4ithTGoM
                ;;
            *)
                coinsutxoamount=$utxoamt
                coinsntraddr=$kmdntrzaddr
                ;;
        esac

        coinstxinfo=$(${coin[1]} listtransactions "" $txscanamount)
        coinslastntrztime=$(echo $coinstxinfo | jq -r --arg address "$coinsntraddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
        coinsntrzd=$(echo $coinstxinfo | jq --arg address "$coinsntraddr" --arg timefilter $timefilter2 '[.[] | select(.time>=($timefilter|tonumber) and .address==$address and .category=="send")] | length')
        otherutxo=$(${coin[1]} listunspent | jq --arg amt "$coinsutxoamount" '[.[] | select(.amount==($amt|tonumber))] | length')
        totalntrzd=$(( $totalntrzd + $coinsntrzd ))
        repo=(${repos[${coin[0]}]})
        balance=$(${coin[1]} getbalance)
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
                "$(${coin[1]} getblockchaininfo | jq .blocks)" \
                "$(timeSince $(${coin[1]} getblock $(${coin[1]} getbestblockhash) | jq .time))" \
                "$(${coin[1]} getnetworkinfo | jq .connections)" \
                ""
    done

    lastcoin=(${coinlist[-1]})
    secondlast=(${coinlist[-2]})
    for coins in "${coinlist[@]}"; do
        coin=($coins)

        if [[ ! ${ignoreacs[*]} =~ ${coin[0]} ]]; then
            info=$($komodoexec -ac_name=${coin[0]} getinfo)
            mininginfo=$($komodoexec -ac_name=${coin[0]} getmininginfo)
            txinfo=$($komodoexec -ac_name=${coin[0]} listtransactions "" $txscanamount)
            lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
            acntrzd=$(echo $txinfo | jq --arg address "$kmdntrzaddr" --arg timefilter $timefilter2 '[.[] | select(.time>=($timefilter|tonumber) and .address==$address and .category=="send")] | length')
            totalntrzd=$(( $totalntrzd + $acntrzd ))
            acutxo=$($komodoexec -ac_name=${coin[0]} listunspent | jq --arg amt "$utxoamt" '[.[] | select(.amount==($amt|tonumber))] | length')
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
                    "$(timeSince $($komodoexec -ac_name=${coin[0]} getblock $($komodoexec -ac_name=${coin[0]} getbestblockhash) | jq .time))" \
                    "$(echo $info | jq .connections)" \
                    "$(ls -lh ~/.komodo/${coin[0]}/wallet.dat  | awk '{print $5}')" \
                    "$laststring"

            if [[ ${coin[0]} != ${lastcoin[0]} ]]; then
                echo
            fi
        fi
    done
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
