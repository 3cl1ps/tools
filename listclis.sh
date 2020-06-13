#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Optionally just get the cli for a single coin
# e.g "KMD"
specific_coin=$1

if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "BTC" ]]; then
  echo bitcoin-cli
fi
if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "KMD" ]]; then
  echo komodo-cli
fi

/home/eclips/komodo/src/listassetchains | while read coin; do
  if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "${coin}" ]]; then
    echo "komodo-cli -ac_name=${coin}"
  fi
done
