#!/bin/bash
source /home/eclips/tools/main
cd "${BASH_SOURCE%/*}" || exit

coin="KMD"
daemon="/home/eclips/komodo/src/komodod -notary -gen -genproclimit=1 -pubkey=${PUBKEY} -minrelaytxfee=0.000035 -opretmintxfee=0.004"
daemon_process_regex="komodod.*\-notary"
cli="komodo-cli"
wallet_file="${HOME}/.komodo/wallet.dat"

/home/eclips/install/walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${KMDADDRESS}"
