#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

coin="CHIPS"
daemon="chipsd -pubkey=$PUBKEY"
daemon_process_regex="chipsd.*\-pubkey"
cli="chips-cli"
wallet_file="${HOME}/.chips/wallet.dat"
nn_address=$KMDADDRESS

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
