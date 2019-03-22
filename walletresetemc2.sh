#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

coin="EMC2"
daemon="einsteiniumd -pubkey=$PUBKEY"
daemon_process_regex="einsteiniumd.*\-pubkey"
cli="einsteinium-cli"
wallet_file="${HOME}/.einsteinium/wallet.dat"
nn_address=$EMC2ADDRESS

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
