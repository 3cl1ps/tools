#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Optionally just get the cli for a single coin
# e.g "KMD"
specific_coin=$1

if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "LTC" ]]; then
  echo litecoin-cli
fi
if [[ -z "${specific_coin}" ]] || [[ "${specific_coin}" = "KMD" ]]; then
  echo komodo-cli
fi
