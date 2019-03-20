#!/bin/bash

sudo apt install libssl-dev

cd ~/
git clone https://github.com/gamecredits-project/GameCredits game
cd game
./autogen.sh
./configure --with-incompatible-bdb --with-gui=no --disable-tests --disable-bench --without-miniupnpc --disable-zmq --enable-experimental-asm
make -j4

mkdir ~/.gamecredits
rm ~/.gamecredits/gamecredits.conf
echo "server=1" >> ~/.gamecredits/gamecredits.conf
echo "txindex=1" >> ~/.gamecredits/gamecredits.conf
echo "listen=0" >> ~/.gamecredits/gamecredits.conf
echo "rpcuser=bartergame" >> ~/.gamecredits/gamecredits.conf
echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >> ~/.gamecredits/gamecredits.conf

#mkdir /data/game
#echo "datadir=/data/game/" >> ~/.gamecredits/gamecredits.conf
chmod 0600 ~/.gamecredits/gamecredits.conf

sudo ln -sf /home/eclips/game/src/gamecredits-cli /usr/local/bin/gamecredits-cli
sudo ln -sf /home/eclips/game/src/gamecreditsd /usr/local/bin/gamecreditsd

gamecreditsd &
