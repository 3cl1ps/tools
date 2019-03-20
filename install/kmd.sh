#!/bin/bash

sudo apt-get install -y dc build-essential pkg-config libc6-dev m4 g++-multilib libsodium-dev autoconf libtool ncurses-dev unzip git python python-zmq zlib1g-dev wget libcurl4-openssl-dev bsdmainutils automake curl

rm -rf komodo
cd ~/
git clone https://github.com/jl777/komodo
cd ~/komodo
git checkout beta
./zcutil/fetch-params.sh
./zcutil/build.sh -j8
mkdir ~/.komodo
rm ~/.komodo/komodo.conf
echo "server=1" >> ~/.komodo/komodo.conf
echo "listen=1" >> ~/.komodo/komodo.conf
echo "txindex=1" >> ~/.komodo/komodo.conf
echo "rpcuser=`head -c 32 /dev/urandom | base64`" >> ~/.komodo/komodo.conf
echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> ~/.komodo/komodo.conf
echo "bind=127.0.0.1" >> ~/.komodo/komodo.conf
echo "rpcbind=127.0.0.1" >> ~/.komodo/komodo.conf
chmod 0600 ~/.komodo/komodo.conf

sudo ln -sf /home/eclips/komodo/src/komodo-cli /usr/local/bin/komodo-cli
sudo ln -sf /home/eclips/komodo/src/komodod /usr/local/bin/komodod

komodod &
