#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

coin="VERUS"
daemon="verusd -pubkey=${PUBKEY}"
daemon_process_regex="verusd.*\-pubkey"
cli="verus"
wallet_file="${HOME}/.komodo/VRSC/wallet.dat"
nn_address=$KMDADDRESS

./walletreset.sh \
    "${coin}" \
    "${daemon}" \
    "${daemon_process_regex}" \
    "${cli}" \
    "${wallet_file}" \
    "${nn_address}"
