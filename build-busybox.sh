#!/bin/bash -e
mkdir -p build
cd build
wget -nc https://busybox.net/downloads/busybox-1.32.0.tar.bz2
tar xfj busybox-1.32.0.tar.bz2
cd busybox-1.32.0
cp ../../busybox-1.32.0-.config .config
patch -p1 <../../busybox-1.32.0-mark-applets.patch
patch -p1 <../../busybox-1.32.0-fixes.patch
make oldconfig
make
cd ../..
