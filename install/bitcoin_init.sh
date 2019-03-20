#!/bin/bash

sudo apt-get update
sudo apt-get upgrade 

sudo apt-get install build-essential pkg-config libc6-dev m4 \
		g++-multilib autoconf libtool ncurses-dev unzip git python \
		zlib1g-dev wget bsdmainutils automake libboost-all-dev \
		libssl-dev libprotobuf-dev protobuf-compiler \
		libqrencode-dev libdb++-dev ntp ntpdate vim software-properties-common \
		curl libevent-dev libcurl4-gnutls-dev cmake clang lsof
    
nanomsg () {
  cd ~
  git clone https://github.com/nanomsg/nanomsg
  cd nanomsg
  cmake . -DNN_TESTS=OFF -DNN_ENABLE_DOC=OFF
  make -j2
  sudo make install
  sudo ldconfig
}

buildbtc () {
  cd ~
  wget https://bitcoincore.org/bin/bitcoin-core-0.16.3/bitcoin-0.16.3-x86_64-linux-gnu.tar.gz
  tar xvzf bitcoin-0.16.3-x86_64-linux-gnu.tar.gz
}

confsetup () {

  mkdir ~/.bitcoin
  echo "server=1" >> ~/.bitcoin/bitcoin.conf
  echo "daemon=1" >> ~/.bitcoin/bitcoin.conf
  echo "txindex=1" >> ~/.bitcoin/bitcoin.conf
  echo "rpcuser=bitcoinrpc" >> ~/.bitcoin/bitcoin.conf
  echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> ~/.bitcoin/bitcoin.conf
  echo "bind=127.0.0.1" >> ~/.bitcoin/bitcoin.conf
  echo "rpcbind=127.0.0.1" >> ~/.bitcoin/bitcoin.conf
  echo "datadir=/bitcoin/" >> ~/.bitcoin/bitcoin.conf
  
  chmod 0600 ~/.bitcoin/bitcoin.conf
}

cd ~
nanomsg
confsetup
buildbtc

sudo ln -sf /home/eclips/bitcoin-0.16.3/bin/bitcoind /usr/local/bin/bitcoind
sudo ln -sf /home/eclips/bitcoin-0.16.3/bin/bitcoin-cli /usr/local/bin/bitcoin-cli
bitcoind
