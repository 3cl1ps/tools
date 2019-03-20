#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

pubkey=$(cat pubkey.txt)

coin="EMC2"
daemon="einsteiniumd -pubkey=${pubkey}"
daemon_process_regex="einsteiniumd.*\-pubkey"
cli="einsteinium-cli"
wallet_file="${HOME}/.einsteinium/wallet.dat"
nn_address="EYbXeAvqRcyw5DSR3Wri2zvKsQrcQG2A1a"

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
