#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

# Coin we're resetting
coin=$1

daemon="komodod $(./listassetchainparams ${coin}) -pubkey=$PUBKEY"
daemon_process_regex="komodod.*\-ac_name=${coin} -"
cli="komodo-cli -ac_name=${coin}"
wallet_file="${HOME}/.komodo/${coin}/wallet.dat"

./walletreset.sh \
  "${coin}" \
  "${daemon}" \
  "${daemon_process_regex}" \
  "${cli}" \
  "${wallet_file}" \
  "${KMD8ADDRESS}"
