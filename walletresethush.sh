#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

coin="HUSH"
daemon="hushd -pubkey=${PUBKEY}"
daemon_process_regex="hushd.*\-pubkey"
cli="hush-cli"
wallet_file="${HOME}/.hush/wallet.dat"
nn_address=$HUSHADDRESS

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
