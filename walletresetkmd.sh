#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

coin="KMD"
daemon="komodod -notary -pubkey=${pubkey}"
daemon_process_regex="komodod.*\-notary"
cli="komodo-cli"
wallet_file="${HOME}/.komodo/wallet.dat"
nn_address=$KMDADDRESS

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${nn_address}"
