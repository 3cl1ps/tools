#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

coin="GIN"
daemon="gincoind -pubkey=${PUBKEY}"
daemon_process_regex="gincoind.*\-pubkey"
cli="gincoin-cli"
wallet_file="${HOME}/.gincoincore/wallet.dat"
nn_address=$GAMEADDRESS

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
