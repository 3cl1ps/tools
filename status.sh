#!/bin/bash
# Suggest using with this command: watch --color -n 60 ./status

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

processlist=(
#'iguana'
'komodod'
'bitcoind'
)

echo -n -e "iguana \t\t"
if ps aux | grep -v grep | grep ${processlist[count]} >/dev/null
then 
    printf "${GREEN} Running ${NC}\n"
else
    printf "${RED} Not Running ${NC}\n"
fi

count=0
while [ "x${processlist[count]}" != "x" ]
do
    echo -n "${processlist[count]}"
    #fixes formating issues
    size=${#processlist[count]}
    if [ "$size" -lt "8" ]
    then
        echo -n -e "\t\t"
    else
        echo -n -e "\t"
    fi
    if ps aux | grep -v grep | grep ${processlist[count]} >/dev/null
    then
        printf "${GREEN} Running ${NC}"
        if [ "$count" = "0" ]
        then
            RESULT="$(komodo-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
            RESULT1="$(komodo-cli -rpcclienttimeout=15  listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
            RESULT2="$(komodo-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat /home/eclips/.komodo/wallet.dat | grep -Po "\d+" | head -1)
        fi
        if [ "$count" = "1" ]
        then
            RESULT="$(bitcoin-cli -rpcclienttimeout=15 listunspent | grep .00010000 | wc -l)"
            RESULT1="$(bitcoin-cli -rpcclienttimeout=15  listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
            RESULT2="$(bitcoin-cli -rpcclienttimeout=15 getbalance)"
            SIZE=$(stat /home/eclips/.bitcoin/wallet.dat | grep -Po "\d+" | head -1)
        fi
        # Check if we have actual results next two lines check for valid number.
        if [[ $RESULT == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT == ?(?([-+])*([0-9])).+([0-9]) ]]
        then
            if [ "$RESULT" -lt "30" ]
            then
                printf  " - UTXOs: ${RED}$RESULT\t${NC}"
            else
                printf  " - UTXOs: ${GREEN}$RESULT\t${NC}"
            fi
        fi

        if [[ $RESULT1 == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT1 == ?(?([-+])*([0-9])).+([0-9]) ]]
        then
            if [ "$RESULT1" -gt "0" ]
            then
                printf  " - Dust: ${RED}$RESULT1\t${NC}"
            else
                printf  " - Dust: ${GREEN}$RESULT1\t${NC}"
            fi
        fi

        if [[ $RESULT2 == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT2 == ?(?([-+])*([0-9])).+([0-9]) ]]
        then
            if (( $(echo "$RESULT2 > 0.1" | bc -l) ));
            then
                printf  " - Funds: ${GREEN}$RESULT2\t${NC}"
            else
                printf  " - Funds: ${RED}$RESULT2\t${NC}"
            fi
        else
            printf "\n"
        fi

        OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
        if [ "$SIZE" -gt "4000000" ]; then
            printf " - ${RED}$OUTSTR${NC}\n"            
        else
            printf " - ${GREEN}$OUTSTR${NC}\n"
        fi

        RESULT=""
        RESULT2=""

    else
        printf "${RED} Not Running ${NC}\n"
    fi
    count=$(( $count +1 ))
done

count=0
$HOME/komodo/src/listassetchains | while read list; do
if [[ "${ignoreacs[@]}" =~ "${list}" ]]; then
    continue
fi

echo -n "${list}"
#fixes formating issues
size=${#list}
if [ "$size" -lt "8" ]
then
    echo -n -e "\t\t"
else
    echo -n -e "\t"
fi
if ps aux | grep -v grep | grep ${list} >/dev/null
then
    printf "${GREEN} Running ${NC}"
    RESULT="$(komodo-cli -rpcclienttimeout=15 -ac_name=${list} listunspent | grep .00010000 | wc -l)"
    RESULT1="$(komodo-cli -ac_name=${list} -rpcclienttimeout=15  listunspent|grep amount|awk '{print $2}'|sed s/.$//|awk '$1 < 0.0001'|wc -l)"
    RESULT2="$(komodo-cli -rpcclienttimeout=15 -ac_name=${list} getbalance)"
    SIZE=$(stat ~/.komodo/${list}/wallet.dat | grep -Po "\d+" | head -1)
    # Check if we have actual results next two lines check for valid number.
    if [[ $RESULT == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT == ?(?([-+])*([0-9])).+([0-9]) ]]
    then
        if [ "$RESULT" -lt "30" ]
        then
            printf  " - UTXOs: ${RED}$RESULT\t${NC}"
        else
            printf  " - UTXOs: ${GREEN}$RESULT\t${NC}"
        fi
    fi

    if [[ $RESULT1 == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT1 == ?(?([-+])*([0-9])).+([0-9]) ]]
    then
        if [ "$RESULT1" -gt "0" ]
        then
            printf  " - Dust: ${RED}$RESULT1\t${NC}"
        else
            printf  " - Dust: ${GREEN}$RESULT1\t${NC}"
        fi
    fi

    if [[ $RESULT2 == ?([-+])+([0-9])?(.*([0-9])) ]] || [[ $RESULT2 == ?(?([-+])*([0-9])).+([0-9]) ]]
    then
        if (( $(echo "$RESULT2 > 0.1" | bc -l) ));
        then
            printf  " - Funds: ${GREEN}$RESULT2\t${NC}"
        else
            printf  " - Funds: ${RED}$RESULT2\t${NC}"
        fi
    else
        printf "\n"
    fi

    OUTSTR=$(echo $SIZE | numfmt --to=si --suffix=B)
    if [ "$SIZE" -gt "4000000" ]; then
        printf " - ${RED}$OUTSTR${NC}\n" 
    else
        printf " - ${GREEN}$OUTSTR${NC}\n"
    fi

    RESULT=""
    RESULT2=""

else
    printf "${RED} Not Running ${NC}\n"
fi
count=$(( $count +1 ))
    done
