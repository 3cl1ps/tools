#!/bin/bash
# GIN build script for Ubuntu & Debian 9 v.3 (c) Decker (and webworker)
berkeleydb () {
    GIN_ROOT=$(pwd)
    GIN_PREFIX="${GIN_ROOT}/db4"
    mkdir -p $GIN_PREFIX
    wget -N 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
    echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef db-4.8.30.NC.tar.gz' | sha256sum -c
    tar -xzvf db-4.8.30.NC.tar.gz
    cd db-4.8.30.NC/build_unix/

    ../dist/configure -enable-cxx -disable-shared -with-pic -prefix=$GIN_PREFIX

    make install
    cd $GIN_ROOT
}

buildgin () {
    git pull
    make clean
    ./autogen.sh
    ./configure LDFLAGS="-L${GIN_PREFIX}/lib/" CPPFLAGS="-I${GIN_PREFIX}/include/" --with-gui=no --disable-tests --disable-bench --without-miniupnpc --enable-experimental-asm --enable-static --disable-shared --without-gui --with-boost-libdir=/usr/local/lib --with-boost-libdir=/usr/lib/x86_64-linux-gnu
    make -j$(nproc)
}

mkdir ~/.gincoincore
rm ~/.gincoincore/gincoin.conf
echo "server=1" >> ~/.gincoincore/gincoin.conf
echo "txindex=1" >> ~/.gincoincore/gincoin.conf
echo "rpcuser=bartergame" >> ~/.gincoincore/gincoin.conf
echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> ~/.gincoincore/gincoin.conf
chmod 0600 ~/.gincoincore/gincoin.conf

cd ~
git clone https://github.com/GIN-coin/gincoin-core gincoin
cd ~/gincoin
berkeleydb
buildgin
sudo ln -sf /home/eclips/gincoin/src/gincoin-cli /usr/local/bin/gincoin-cli
sudo ln -sf /home/eclips/gincoin/src/gincoind /usr/local/bin/gincoind
