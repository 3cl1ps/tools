#!/bin/bash
#cd "${BASH_SOURCE%/*}" || exit
source /home/eclips/tools/main
# Coin we're resetting
coin=$1

daemon="komodod $(/home/eclips/tools/listassetchainparams ${coin}) -pubkey=$PUBKEY"
daemon_process_regex="komodod.*\-ac_name=${coin} -"
cli="komodo-cli -ac_name=${coin}"
wallet_file="${HOME}/.komodo/${coin}/wallet.dat"

/home/eclips/tools/walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${KMDADDRESS}"
