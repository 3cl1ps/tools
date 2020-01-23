#!/usr/bin/env bash
# Find out the size of KMD and other KMD assetchains

# Credits decker, jeezy

RESET="\033[0m"
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

function show_walletsize () {
  if [ "$1" != "KMD" ] && [ "$1" != "BTC" ]; then
    if [ -f ~/.komodo/$1/wallet.dat ]; then
      SIZE=$(stat --printf="%s"  /home/eclips/.komodo/$1/wallet.dat)
      if [ "$SIZE" -gt "4000000" ]; then
        /home/eclips/tools/walletresetac.sh $1
      fi
    else
      SIZE=0
    fi
  elif [ "$1" = "KMD" ]; then
    SIZE=$(stat --printf="%s"  /home/eclips/.komodo/wallet.dat)
    if [ "$SIZE" -gt "4000000" ]; then
      /home/eclips/tools/walletresetkmd.sh
    fi
  fi
}

ignore_list=(
  VOTE2018
  VOTE2019
  PIZZA
  BEER
  VRSC
  PIRATE
)

show_walletsize KMD
#show_walletsize BTC

# Only assetchains
${HOME}/komodo/src/listassetchains | while read list; do
  if [[ "${ignore_list[@]}" =~ "${list}" ]]; then
    continue
  fi
  show_walletsize $list
done
