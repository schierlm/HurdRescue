#!/bin/bash -e
mkdir -p build/iso/boot/grub
cp grub.cfg build/iso/boot/grub
echo 'source /boot/grub/grub.cfg' >build/iso/boot/grub/loopback.cfg
cp /boot/gnumach-1.8-486.gz /hurd/ext2fs.static /lib/ld.so build/iso/boot
gzip --best <build/rootfs >build/iso/boot/rootfs.gz
grub-mkrescue -o build/HurdRescue.iso build/iso --compress=gz --fonts=ascii --locales="" --themes="" \
	--install-modules="multiboot reboot halt echo cat normal ls part_msdos iso9660 fat ext2"
echo Done.
