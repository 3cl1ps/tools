#!/bin/bash
addr_ecl=RYFxQivEUrPor7Xmfu1dGECsKGSLewdtXa
addr_lud=RLuMarLEz4M956kJ25YLe6jWDawYxeq9Qj
addr_yassin=RMYE5A2qPwWYXKjELBfa2jTfPj3FFdsCFD
triggerPai=8
balance=$(komodo-cli getbalance)
echo $balance

tour=0
while true; do
    case $tour in
        0)
            addr=$addr_yassin
            while ! ./payday3 $addr; do  
                sleep 1
            done
            #echo paiement yassin
            ;;
        1)
            addr=$addr_lud
            while ! ./payday3 $addr; do  
                sleep 1
            done
            #echo paiement lud
            ;;
        2)
            addr=$addr_ecl
            while ! ./payday3 $addr; do  
                sleep 1
            done
            #echo paiement eclips
            ;;
        *)
            echo error $tour
            ;;
    esac
    tour=$(($tour + 1))
    if [ $tour -eq 3 ]; then tour=0; echo reset; fi
    #sleep 72000 #20h
    sleep 1
done
