#!/bin/bash
addr_ecl=RYFxQivEUrPor7Xmfu1dGECsKGSLewdtXa
addr_lud=RLuMarLEz4M956kJ25YLe6jWDawYxeq9Qj
addr_yassin=RMYE5A2qPwWYXKjELBfa2jTfPj3FFdsCFD

tour=0
while true; do
    case $tour in
        0)
            addr=$addr_yassin
            echo -n "paiement yassin;"
            while ! ./payday3 $addr; do  
                sleep 300
            done
            ;;
        1)
            addr=$addr_lud
            echo -n "paiement ludom;"
            while ! ./payday3 $addr; do  
                sleep 300
            done
            ;;
        2)
            addr=$addr_ecl
            echo -n "paiement eclips;"
            while ! ./payday3 $addr; do  
                sleep 300
            done
            ;;
        *)
            echo error $tour
            ;;
    esac
    tour=$(($tour + 1))
    if [ $tour -eq 3 ]; then tour=0; echo reset; fi
    /home/eclips/tools/cleanwallettransactions.sh >/dev/null >> /tmp/resetwalletkmd.log
    sleep 50
    /home/eclips/tools/consolidateutxos.sh "KMD" 0.0001 >/dev/null >> /tmp/resetwalletkmd.log
    sleep 10
done
