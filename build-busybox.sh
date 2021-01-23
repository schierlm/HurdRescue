#!/bin/bash -e
mkdir -p build
cd build
wget -nc https://busybox.net/downloads/busybox-1.33.0.tar.bz2
tar xfj busybox-1.33.0.tar.bz2
cd busybox-1.33.0
cp ../../busybox-1.33.0-.config .config
make oldconfig
make
cd ../..
