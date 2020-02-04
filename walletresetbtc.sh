#!/bin/bash
cd "${BASH_SOURCE%/*}" || exit

coin="BTC"
daemonbtc="bitcoind -deprecatedrpc=estimatefee"
daemon_process_regex="bitcoind"
cli="bitcoin-cli"
if [ -e /home/eclips/.bitcoin/wallet.dat ]; then
    wallet_file="/home/eclips/.bitcoin/wallet.dat"
fi
if [ -e /bitcoin/wallet.dat ]; then
    wallet_file="/bitcoin/wallet.dat"
fi

./walletreset.sh \
    "${coin}" \
    "${daemonbtc}" \
    "${daemon_process_regex}" \
    "${cli}" \
    "${wallet_file}" \
    "${BTCADDRESS}"
