#!/bin/bash
# EMC2 build script for Ubuntu & Debian 9 v.3 (c) Decker (and webworker)
cd ~
git clone https://github.com/emc2foundation/einsteinium.git 
cd einsteinium
git checkout master
git pull

berkeleydb () {
    EMC2_ROOT=$(pwd)
    EMC2_PREFIX="${EMC2_ROOT}/db4"
    mkdir -p $EMC2_PREFIX
    wget -N 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
    echo '12edc0df75bf9abd7f82f821795bcee50f42cb2e5f76a6a281b85732798364ef db-4.8.30.NC.tar.gz' | sha256sum -c
    tar -xzvf db-4.8.30.NC.tar.gz
    cd db-4.8.30.NC/build_unix/

    ../dist/configure -enable-cxx -disable-shared -with-pic -prefix=$EMC2_PREFIX

    make install
    cd $EMC2_ROOT
}

buildemc2 () {
    make clean
    ./autogen.sh
    ./configure LDFLAGS="-L${EMC2_PREFIX}/lib/" CPPFLAGS="-I${EMC2_PREFIX}/include/" --with-gui=no --disable-tests --disable-bench --without-miniupnpc --enable-experimental-asm --enable-static --disable-shared
    make -j$(nproc)
}
#rm -rf ~/.einsteinium
#rm -rf ~/einsteinium

mkdir ~/.einsteinium
rm ~/.einsteinium/einsteinium.conf
echo "txindex=1" >> ~/.einsteinium/einsteinium.conf
echo "server=1" >> ~/.einsteinium/einsteinium.conf
echo "listen=0" >> ~/.einsteinium/einsteinium.conf
echo "rpcuser=`head -c 32 /dev/urandom | base64`" >> ~/.einsteinium/einsteinium.conf
echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> ~/.einsteinium/einsteinium.conf
chmod 0600 ~/.einsteinium/einsteinium.conf

berkeleydb
buildemc2

sudo ln -sf /home/eclips/einsteinium/src/einsteinium-cli /usr/local/bin/einsteinium-cli
sudo ln -sf /home/eclips/einsteinium/src/einsteiniumd /usr/local/bin/einsteiniumd

einsteiniumd &
