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

checkRepo () {
    if [ -z $1 ] ; then
        return
    fi
    repo=(${repos[$1]})
    prevdir=${PWD}

    cd $repo

    git remote update > /dev/null 2>&1

    localrev=$(git rev-parse HEAD)
    remoterev=$(git rev-parse ${repo[1]})
    cd $prevdir

    if [ $localrev != $remoterev ]; then
        printf "${RED}[U]${NC}"
    fi
}

printf "%-9s %3s" "iguana" $(checkRepo dPoW)
if ps aux | grep -v grep | grep iguana >/dev/null
then 
    printf "${GREEN} Running${NC}\n"
else
    printf "${RED} Not Running${NC}\n"
fi


processlist=(
'komodod'
'bitcoind'
'verusd'
)

count=0
while [ "x${processlist[count]}" != "x" ]
do
    repo=(${repos[KMD]})
    printf "%-9s %3s" ${processlist[count]} $(checkRepo KMD)
    if ps aux | grep -v grep | grep ${processlist[count]} >/dev/null
    then
        printf "${GREEN} Running ${NC}"
        if [ "$count" = "0" ]
        then
            RESULT="$(komodo-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
            RESULT1="$(komodo-cli -rpcclienttimeout=15  listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
            RESULT2="$(komodo-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat --printf="%s" /home/eclips/.komodo/wallet.dat)
            TIME=$((time komodo-cli listunspent) 2>&1 >/dev/null)
            txinfo=$(komodo-cli listtransactions "" $txscanamount)
            lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        fi
        if [ "$count" = "1" ]
        then
            RESULT="$(bitcoin-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
            RESULT1="$(bitcoin-cli -rpcclienttimeout=15  listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
            RESULT2="$(bitcoin-cli -rpcclienttimeout=15 getbalance)"
            txinfo=$(bitcoin-cli listtransactions "" $txscanamount)
            lastntrztime=$(echo $txinfo | jq -r --arg address "$btcntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')

            if [ -e /home/eclips/.bitcoin/wallet.dat ]
            then
                SIZE=$(stat --printf="%s" /home/eclips/.bitcoin/wallet.dat)
            fi
            if [ -e /bitcoin/wallet.dat ]
            then
                SIZE=$(stat --printf="%s" /bitcoin/wallet.dat)
            fi
            TIME=$((time bitcoin-cli listunspent) 2>&1 >/dev/null)
        fi
        if [ "$count" = "2" ]
        then
            RESULT="$(verus -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
            RESULT1="$(verus -rpcclienttimeout=15  listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
            RESULT2="$(verus -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat --printf="%s" /home/eclips/.komodo/VRSC/wallet.dat)
            TIME=$((time verus listunspent) 2>&1 >/dev/null)
            txinfo=$(verus listtransactions "" $txscanamount)
            lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"') 
        fi
        # Check if we have actual results next two lines check for valid number.
        if [[ $RESULT == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT == ?(?([-+])*([0-9])).+([0-9]) ]]
        then
            if [[ "$RESULT" -lt "15" ]] || [[ "$RESULT" -gt "50" ]]
            then
                printf  " - UTXOs: ${RED}%3s${NC}" $RESULT
            else
                printf  " - UTXOs: ${GREEN}%3s${NC}" $RESULT
            fi
        fi

        if [[ $RESULT1 == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT1 == ?(?([-+])*([0-9])).+([0-9]) ]]
        then
            if [ "$RESULT1" -gt "0" ]
            then
                printf  " - Dust: ${RED}%3s${NC}" $RESULT1
            else
                printf  " - Dust: ${GREEN}%3s${NC}" $RESULT1
            fi
        fi

        if [[ $RESULT2 == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT2 == ?(?([-+])*([0-9])).+([0-9]) ]]
        then
            if (( $(echo "$RESULT2 > 0.1" | bc -l) ));
            then
                printf " - Funds: ${GREEN}%10.2f${NC}" $RESULT2
            else
                printf " - Funds: ${RED}%10.2f${NC}" $RESULT2
            fi
        else
            printf "\n"
        fi

        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - WSize: ${RED}%5s${NC}" $OUTSTR           
        else
            printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
        fi

        if [[ "$TIME" > "0.05" ]]; then
            printf " - Time: ${RED}%3ss${NC}" $TIME          
        else
            printf " - Time: ${GREEN}%3ss${NC}" $TIME
        fi

        #if [[ "$lastntrztime" > "0.1" ]]; then
        #    printf " - ${RED}%3ss${NC}" $TIME          
        #else
        printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)
        #fi


        printf "\n"
        RESULT=""
        RESULT1=""
        RESULT2=""
        SIZE=""
        TIME=""

    else
        printf "${RED} Not Running ${NC}\n"
    fi
    count=$(( $count +1 ))
done

count=0
$HOME/tools/listassetchains | while read list; do
printf "%-13s" "${list}"
if ps aux | grep -v grep | grep ${list} >/dev/null
then
    printf "${GREEN} Running ${NC}"
    RESULT="$(komodo-cli -rpcclienttimeout=15 -ac_name=${list} listunspent | grep .00010000 | wc -l)"
    RESULT1="$(komodo-cli -ac_name=${list} -rpcclienttimeout=15  listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
    RESULT2="$(komodo-cli -rpcclienttimeout=15 -ac_name=${list} getbalance)"
    SIZE=$(stat --printf="%s" ~/.komodo/${list}/wallet.dat)
    TIME=$((time komodo-cli -ac_name=${list} listunspent) 2>&1 >/dev/null)
    txinfo=$(komodo-cli -ac_name=${list} listtransactions "" $txscanamount)
    lastntrztime=$(echo $txinfo | jq -r --arg address "$kmdntrzaddr" '[.[] | select(.address==$address)] | sort_by(.time) | last | "\(.time)"')
    # Check if we have actual results next two lines check for valid number.
    if [[ $RESULT == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT == ?(?([-+])*([0-9])).+([0-9]) ]]
    then
        if [[ "$RESULT" -lt "30" ]] || [[ "$RESULT" -gt "110" ]]
        then
            printf  " - UTXOs: ${RED}%3s${NC}" $RESULT
        else
            printf  " - UTXOs: ${GREEN}%3s${NC}" $RESULT
        fi
    fi

    if [[ $RESULT1 == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT1 == ?(?([-+])*([0-9])).+([0-9]) ]]
    then
        if [ "$RESULT1" -gt "0" ]
        then
            printf  " - Dust: ${RED}%3s${NC}" $RESULT1
        else
            printf  " - Dust: ${GREEN}%3s${NC}" $RESULT1
        fi
    fi

    if [[ $RESULT2 == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT2 == ?(?([-+])*([0-9])).+([0-9]) ]]
    then
        if (( $(echo "$RESULT2 > 0.1" | bc -l) ));
        then
            printf " - Funds: ${GREEN}%10.2f${NC}" $RESULT2
        else
            printf " - Funds: ${RED}%10.2f${NC}" $RESULT2
        fi
    fi

    OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
    if [ "$SIZE" -gt "4000000" ]; then
        printf " - WSize: ${RED}%5s${NC}" $OUTSTR 
    else
        printf " - WSize: ${GREEN}%5s${NC}" $OUTSTR
    fi

    if [[ "$TIME" > "0.05" ]]; then
        printf " - Time: ${RED}%5ss${NC}" $TIME          
    else
        printf " - Time: ${GREEN}%5ss${NC}" $TIME
    fi

    printf " - LastN: ${GREEN}%6s${NC}" $(timeSince $lastntrztime)

    if [[ "$(/home/eclips/tools/checkfork2.sh ${list})" == "1" ]]; then
        printf " ${RED}Fork!${NC}" 
    fi

    printf "\n"
    RESULT=""
    RESULT1=""
    RESULT2=""
    TIME=""
    SIZE=""

else
    printf "${RED} Not Running ${NC}\n"
fi
count=$(( $count +1 ))
    done
