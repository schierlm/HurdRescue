#!/bin/bash -e
mkdir -p build/mnt
dd if=/dev/zero of=build/rootfs bs=1M count=35
mkfs.ext2 build/rootfs
mount build/rootfs build/mnt
cd build/mnt
mkdir bin dev home hurd root sbin tmp var
mkdir -p servers/{socket,bus} usr/{,s}bin lib/{terminfo/h,i386-gnu/hurd/console}
mkdir -p etc/hurd usr/share/X11/{xkb/{keymap,keycodes,symbols},locale}
settrans -c proc /hurd/procfs
cp -r /usr/share/X11/xkb/{compat,types} usr/share/X11/xkb
cp /usr/share/X11/xkb/keycodes/xfree86 usr/share/X11/xkb/keycodes
cp /usr/share/X11/xkb/keymap/hurd usr/share/X11/xkb/keymap/hurd
cp /usr/share/X11/xkb/symbols/* usr/share/X11/xkb/symbols 2>&1 | grep -v omitting.*_vndr || true
touch usr/share/X11/locale/'(null)'
cd dev
for d in {c,f}d{0,1}; do
	settrans -c $d /hurd/storeio $d
done
for d in console com{0,1,2,3}; do
	settrans -c $d /hurd/term /dev/$d device $d
done
for d in eth{0,1,2,3}; do
	settrans -c $d /hurd/devnode -M /dev/netdde $d
done
settrans -c fd /hurd/magic --directory fd
settrans -c full /hurd/null --full
for d in {s,h}d{0,1,2,3,4,5}; do
	settrans -c $d /hurd/storeio $d
	for i in `seq 16`; do
		settrans -c ${d}s${i} /hurd/storeio ${d}s${i}
	done
done
for d in kbd mouse; do
	ln -s cons/$d $d
done
settrans -c cons /bin/console
settrans -c klog /hurd/streamio kmsg
settrans -c log /hurd/ifsock
for d in lpr{0,1,2}; do
	settrans -c $d /hurd/streamio $d
done
settrans -c mem /hurd/storeio --no-cache mem
settrans -c netdde /hurd/netdde
settrans -c null /hurd/null
for d in ty{p,q}{{0..9},{a..v}}; do
	settrans -c p$d /hurd/term /dev/p$d pty-master /dev/t$d
	settrans -c t$d /hurd/term /dev/t$d pty-slave /dev/p$d
done
settrans -c random /hurd/random --seed-file /lib/random-seed
settrans -c urandom /hurd/random --seed-file /lib/random-seed --fast
ln -s fd/0 stdin
ln -s fd/1 stdout
ln -s fd/2 stderr
settrans -c time /hurd/storeio --no-cache time
settrans -c tty /hurd/magic tty
for i in `seq 9`; do
	settrans -c tty$i /hurd/term /dev/tty$i hurdio /dev/vcs/$i/console
done
settrans -c vcs /hurd/console
ln -s xconsole
settrans -c zero /bin/nullauth -- /hurd/storeio -Tzero
cd ../etc
touch fstab
ln -s /proc/mounts mtab
echo 'root::0:0:root:/root:/bin/sh' >passwd
echo 'hosts: dns' >nsswitch.conf
echo 'export TERM=hurd' >profile
echo 'nameserver 10.0.2.2' >resolv.conf
cp ../../../{console,inittab} .
cp ../../../runsystem hurd
chmod a+x console hurd/runsystem
cd ../servers/socket
settrans -c 1 /hurd/pflocal
settrans -c 2 /hurd/pfinet --interface=/dev/eth0 --address=10.0.2.15 --netmask=255.255.255.0 --gateway=10.0.2.2 -6 /servers/socket/26
settrans -c 26 /hurd/pfinet --interface=/dev/eth0 --address=10.0.2.15 --netmask=255.255.255.0 --gateway=10.0.2.2 -4 /servers/socket/2
ln -s 1 local
ln -s 2 inet
ln -s 26 inet6
cd ..
ln -s crash-kill crash
for s in acpi exec password shutdown; do
	settrans -c $s /hurd/$s
done
settrans -c bus/pci /hurd/pci-arbiter
settrans -c crash-dump-core /hurd/crash --dump-core
settrans -c crash-kill /hurd/crash --kill
settrans -c crash-suspend /hurd/crash --suspend
settrans -c default-pager /hurd/proxy-defpager
touch startup
cd ..
for f in acpi auth console crash devnode eth-multiplexer exec ext2fs fakeroot fifo firmlink fwd hello \
		hello-mt hostmux ifsock init lwip mach-defpager magic mtab netdde new-fifo nfs null \
		password pci-arbiter pfinet pflocal proc procfs proxy-defpager random remap rumpdisk shutdown \
		 startup storeio streamio symlink term tmpfs usermux; do
	cp /hurd/$f hurd
done
cp /var/lib/random-seed lib
cp /lib/ld.so.1 lib
ln -s ld.so.1 lib/ld.so
cp /lib/terminfo/h/hurd lib/terminfo/h/hurd
for f in libbpf.so.0.3 libbz2.so.1 libbz2.so.1.0 libc.so.0.3 libcom_err.so.2 libcons.so.0.3 libdiskfs.so.0.3 libdl.so.2 \
		libe2p.so.2 libext2fs.so.2 libfshelp.so.0.3 libftpconn.so.0.3 libgpg-error.so.0 libhurd-slab.so.0.3 libhurduser.so.0.3 \
		libihash.so.0.3 libiohelp.so.0.3 liblzma.so.5 libm.so.6 libmachdev.so.0.3 libmachdevdde.so.0.3 libmachuser.so.1 \
		libncursesw.so.6 libnetfs.so.0.3 libpager.so.0.3 libparted.so.2 libpipe.so.0.3 libports.so.0.3 libps.so.0.3 \
		libpthread.so.0.3 libresolv.so.2 libshouldbeinlibc.so.0.3 libstore.so.0.3 libtinfo.so.6 libtrivfs.so.0.3 \
		libz.so.1 libnss_dns.so.2; do
	cp /lib/i386-gnu/$f lib
done
for f in libblkid.so.1 libcrypt.so.1 libdaemon.so.0 libfdisk.so.1 libgcrypt.so.20 liblwip.so.0 libmount.so.1 libpciaccess.so.0 \
		libsmartcols.so.1 libuuid.so.1 libxml2.so.2 libX11.so.6 libxcb.so.1 libXau.so.6 libXdmcp.so.6 libbsd.so.0; do
	cp /usr/lib/i386-gnu/$f lib
done
for f in vga pc_kbd generic_speaker; do
	cp /lib/i386-gnu/hurd/console/$f.so.0.3 lib/i386-gnu/hurd/console
done
cp ../busybox-1.33.0/busybox bin
chroot . /bin/busybox --install -s
for f in bash console fsysopts {,u}mount nullauth s{et,how}trans; do
	cp /bin/$f bin
done
for f in cfdisk console-run e2fsck resize2fs; do
	cp /sbin/$f sbin
done
cp /usr/sbin/zerofree sbin
cd ../..
umount -f build/mnt
echo Done.
