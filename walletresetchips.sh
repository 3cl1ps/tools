#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

pubkey=$(cat pubkey.txt)

coin="CHIPS"
daemon="chipsd -pubkey=${pubkey}"
daemon_process_regex="chipsd.*\-pubkey"
cli="chips-cli"
wallet_file="${HOME}/.chips/wallet.dat"
nn_address="RQipE6ycbVVb9vCkhqrK8PGZs2p5YmiBtg"

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
