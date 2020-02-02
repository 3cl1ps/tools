#!/bin/bash
# Suggest using with this command: watch --color -n 60 ./status
scriptpath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source $scriptpath/main
TIMEFORMAT=%R
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
btcntrzaddr=1P3rU1Nk1pmc2BiWC8dEy9bZa1ZbMp5jfg
kmdntrzaddr=RXL3YXG2ceaB6C5hfJcN4fvmLH2C34knhA

printf "%-9s" "iguana"
if ps aux | grep -v grep | grep iguana >/dev/null
then 
    printf "${GREEN} Run${NC}\n"
else
    printf "${RED} Not Run${NC}\n"
fi

printf "%-9s" "komodod"
if ps aux | grep -v grep | grep komodod >/dev/null; then
    balance="$(komodo-cli -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $balance == ?(?([-+])*([0-9])).+([0-9]) ]]; then
        printf "${GREEN} Run${NC}"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%10.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%10.2f${NC}" $balance
        fi
        listunspent="$(komodo-cli -rpcclienttimeout=15 listunspent 2>&1 | grep .00010000 | wc -l)"
        # Check if we have actual results next two lines check for valid number.
        if [[ $listunspent == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $listunspent == ?(?([-+])*([0-9])).+([0-9]) ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(komodo-cli -rpcclienttimeout=15 listunspent 2>&1|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
        if [[ $countunspent == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $countunspent == ?(?([-+])*([0-9])).+([0-9]) ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.komodo/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time komodo-cli listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(komodo-cli listtransactions "" $txscanamount 2>&1)
        lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        now=$(date +%s)
        window=$(echo "$now - 3*3600" | bc -l)
        speed=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        if [[ "$speed" < "100" ]]; then
            printf " - S: ${RED}%3s${NC}" $speed  
        else
            printf " - S: ${GREEN}%3s${NC}" $speed
        fi
    else
        printf "${YELLOW} Loading ${NC}"
    fi
    balance=""
    listunspent=""
    countunspent=""
    balance=""
    TIME=""
    SIZE=""
    OUTSTR=""
    txinfo=""
    lastntrztime=""
    printf "\n"
fi

printf "%-9s" "bitcoind"
if ps aux | grep -v grep | grep bitcoind >/dev/null; then
    balance="$(bitcoin-cli -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $balance == ?(?([-+])*([0-9])).+([0-9]) ]]; then
        printf "${GREEN} Run${NC}"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%10.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%10.2f${NC}" $balance
        fi
        listunspent="$(bitcoin-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
        if [[ $listunspent == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $listunspent == ?(?([-+])*([0-9])).+([0-9]) ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(bitcoin-cli -rpcclienttimeout=15  listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
        if [[ $countunspent == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $countunspent == ?(?([-+])*([0-9])).+([0-9]) ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi

        if [ -e /home/eclips/.bitcoin/wallet.dat ]; then
            SIZE=$(stat --printf="%s" /home/eclips/.bitcoin/wallet.dat)
        fi
        if [ -e /bitcoin/wallet.dat ]; then
            SIZE=$(stat --printf="%s" /bitcoin/wallet.dat)
        fi
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time bitcoin-cli listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(bitcoin-cli listtransactions "" $txscanamount)
        lastntrztime=$(echo $txinfo | jq -r --arg address "$btcntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        now=$(date +%s)
        window=$(echo "$now - 3*3600" | bc -l)
        speed=$(echo $txinfo | jq -r --arg address "$btcntrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        if [[ "$speed" < "100" ]]; then
            printf " - S: ${RED}%3s${NC}" $speed  
        else
            printf " - S: ${GREEN}%3s${NC}" $speed
        fi
    else
        printf "${YELLOW} Loading ${NC}"
    fi
    balance=""
    listunspent=""
    countunspent=""
    balance=""
    TIME=""
    SIZE=""
    OUTSTR=""
    txinfo=""
    lastntrztime=""
    printf "\n"
fi

printf "%-9s" "verusd"
if ps aux | grep -v grep | grep verusd >/dev/null; then
    balance="$(verus -rpcclienttimeout=15 getbalance 2>&1)"
    if [[ $balance == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $balance == ?(?([-+])*([0-9])).+([0-9]) ]]; then
        printf "${GREEN} Run${NC}"
        if (( $(echo "$balance > 0.1" | bc -l) )); then
            printf " - Funds: ${GREEN}%10.2f${NC}" $balance
        else
            printf " - Funds: ${RED}%10.2f${NC}" $balance
        fi
        listunspent="$(verus -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
        if [[ $listunspent == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $listunspent == ?(?([-+])*([0-9])).+([0-9]) ]]; then
            if [[ "$listunspent" -lt "15" ]] || [[ "$listunspent" -gt "50" ]]; then
                printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
            fi
        fi
        countunspent="$(verus -rpcclienttimeout=15 listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
        if [[ $countunspent == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $countunspent == ?(?([-+])*([0-9])).+([0-9]) ]]; then
            if [ "$countunspent" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $countunspent
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
            fi
        fi
        SIZE=$(stat --printf="%s" /home/eclips/.komodo/VRSC/wallet.dat)
        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi
        TIME=$((time verus listunspent) 2>&1 >/dev/null)
        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi
        txinfo=$(verus listtransactions "" $txscanamount)
        lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #speed
        now=$(date +%s)
        window=$(echo "$now - 3*3600" | bc -l)
        speed=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
        if [[ "$speed" < "100" ]]; then
            printf " - S: ${RED}%3s${NC}" $speed  
        else
            printf " - S: ${GREEN}%3s${NC}" $speed
        fi
    else
        printf "${YELLOW} Loading ${NC}"
    fi
    balance=""
    listunspent=""
    countunspent=""
    balance=""
    TIME=""
    SIZE=""
    OUTSTR=""
    txinfo=""
    lastntrztime=""
    printf "\n"
else
    printf "${RED} Not Run ${NC}\n"
fi

$HOME/tools/listassetchains | while read list; do
if [[ ! ${ignoreacs[*]} =~ ${list} ]]; then
    printf "%-9s" "${list}"
    if ps aux | grep -v grep | grep ${list} >/dev/null
    then
        balance="$(komodo-cli -rpcclienttimeout=15 -ac_name=${list} getbalance 2>&1)"
        if [[ $balance == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $balance == ?(?([-+])*([0-9])).+([0-9]) ]]; then
            printf "${GREEN} Run${NC}"
            if (( $(echo "$balance > 0.1" | bc -l) )); then
                printf " - Funds: ${GREEN}%10.2f${NC}" $balance
            else
                printf " - Funds: ${RED}%10.2f${NC}" $balance
            fi
            listunspent="$(komodo-cli -rpcclienttimeout=15 -ac_name=${list} listunspent 2>&1 | grep .00010000 | wc -l)"
            # Check if we have actual results next two lines check for valid number.
            if [[ $listunspent == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $listunspent == ?(?([-+])*([0-9])).+([0-9]) ]]; then
                if [[ "$listunspent" -lt "30" ]] || [[ "$listunspent" -gt "110" ]]; then
                    printf  " - UTXOs: ${RED}%3s${NC}" $listunspent
                else
                    printf  " - UTXOs: ${GREEN}%3s${NC}" $listunspent
                fi
            fi
            countunspent="$(komodo-cli -ac_name=${list} -rpcclienttimeout=15 listunspent 2>&1 |grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
            if [[ $countunspent == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $countunspent == ?(?([-+])*([0-9])).+([0-9]) ]]; then
                if [ "$countunspent" -gt "0" ]; then
                    printf  " - Dust: ${RED}%3s${NC}" $countunspent
                else
                    printf  " - Dust: ${GREEN}%3s${NC}" $countunspent
                fi
            fi
            SIZE=$(stat --printf="%s" ~/.komodo/${list}/wallet.dat)
            OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
            if [ "$SIZE" -gt "4000000" ]; then
                printf " - WSize: ${RED}%5s${NC}" $OUTSTR 
            else
                printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
            fi
            TIME=$((time komodo-cli -ac_name=${list} listunspent) 2>&1 >/dev/null)
            if [[ "$TIME" > "0.05" ]]; then
                printf " - Time: ${RED}%5ss${NC}" $TIME          
            else
                printf " - Time: ${GREEN}%5ss${NC}" $TIME
            fi
            txinfo=$(komodo-cli -ac_name=${list} listtransactions "" $txscanamount 2>&1)
            lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
            printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
            #speed
            now=$(date +%s)
            window=$(echo "$now - 3*3600" | bc -l)
            speed=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" --argjson window "$window" '[.[] | select(.address==$address and .time > $window)] | length')
            if [[ "$speed" < "100" ]]; then
                printf " - S: ${RED}%3s${NC}" $speed  
            else
                printf " - S: ${GREEN}%3s${NC}" $speed
            fi
        else
            printf "${YELLOW} Loading ${NC}\n"
            continue
        fi
        balance=""
        listunspent=""
        countunspent=""
        balance=""
        TIME=""
        SIZE=""
        OUTSTR=""
        txinfo=""
        lastntrztime=""
        printf "\n"
    else
        printf "${RED} Not Run ${NC}\n"
    fi
fi
done
