#!/bin/bash
addr_ecl=RYFxQivEUrPor7Xmfu1dGECsKGSLewdtXa
#addr_lud
#addr_yassin

tour=0
while true; do
    case $tour in

        0)
            echo paiement yassin
            #/home/eclips/tools/payday3 $addr_yassin
            ;;

        1)
            echo paiement lud
            #/home/eclips/tools/payday3 $addr_lud
            ;;

        2)
            echo paiement ecl
            #/home/eclips/tools/payday3 $addr_ecl
            ;;

        *)
            echo error $tour
            ;;
    esac
    tour=$(($tour + 1))
    if [ $tour -eq 3 ]; then tour=0; echo reset; fi
    sleep 1
done
