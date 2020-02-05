#!/bin/bash
source /home/eclips/tools/main
cd "${BASH_SOURCE%/*}" || exit

coin="KMD"
daemon="komodod -notary -gen -genproclimit=1 -pubkey=${PUBKEY}"
daemon_process_regex="komodod.*\-notary"
cli="komodo-cli"
wallet_file="${HOME}/.komodo/wallet.dat"

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${KMDADDRESS}"
