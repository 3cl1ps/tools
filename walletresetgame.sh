#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

coin="GAME"
daemon="gamecreditsd -pubkey=$PUBKEY"
daemon_process_regex="gamecreditsd.*\-pubkey"
cli="gamecredits-cli"
wallet_file="${HOME}/.gamecredits/wallet.dat"
nn_address=$GAMEADDRESS

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
