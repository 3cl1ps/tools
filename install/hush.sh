#!/bin/bash
# install build depedencies
sudo apt-get install build-essential pkg-config libc6-dev m4 g++-multilib \
      autoconf libtool ncurses-dev unzip git python zlib1g-dev wget \
      bsdmainutils automake curl unzip nano
# pull
cd ~
git clone https://github.com/MyHush/hush.git
cd hush
# Build
./zcutil/build.sh -j$(nproc)
./zcutil/fetch-params.sh

mkdir -p ~/.hush
rm ~/.hush/hush.conf
echo "rpcuser=username" >> ~/.hush/hush.conf
echo "rpcpassword=`head -c 32 /dev/urandom | base64`" >>~/.hush/hush.conf
echo "addnode=explorer.myhush.org" >> ~/.hush/hush.conf
echo "addnode=dnsseed.myhush.org" >> ~/.hush/hush.conf
echo "addnode=dnsseed2.myhush.org" >> ~/.hush/hush.conf
echo "addnode=dnsseed.bleuzero.com" >> ~/.hush/hush.conf
echo "addnode=dnsseed.hush.quebec" >> ~/.hush/hush.conf
echo "txindex=1" >> ~/.hush/hush.conf
echo "server=1" >> ~/.hush/hush.conf
echo "showmetrics=0" >> ~/.hush/hush.conf

sudo ln -sf /home/eclips/hush/src/hush-cli /usr/local/bin/hush-cli
sudo ln -sf /home/eclips/hush/src/hushd /usr/local/bin/hushd
hushd &
