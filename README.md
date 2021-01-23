# HurdRescue

Minimal rescue system for GNU/Hurd

## Description

There are tons of rescue environments available for (GNU/)Linux, yet when your (experimental) GNU/Hurd system breaks,
you have to try mounting the broken disk from another (installed) Hurd system.

Therefore, this repository provides a small busybox-based rescue system, that can be used to repair Hurd installations.

Focus is on things that cannot be repaired from a Linux system (e.g. related to the special translator inodes found in
Hurd's filesystem), but common VM tasks like enlarging a partition should also be possible.

The upstream GNU Mach kernel does not support any way to boot from initial ramdisks or similar (the most similar thing available
is to boot from a `copy:device:hd1s1` store, which will copy the whole partition to RAM before booting it). This is unfortunate,
as I'd like to be able to boot the system from a loopback ISO image. Luckily, the Debian GNU/Hurd comes with a patched
GNU Mach, which supports `$(ramdisk-create)` for modules.

Therefore, to build this rescue system, you have to be on Debian GNU/Hurd, as it will just copy the Hurd and Mach files from
your running system.

## Using the rescue system

The Releases section should include an `.iso` image.

It is isohybrid and contains loopback.cfg. So there are three ways of running it:

- Burn onto a (virtual) CD
- `dd` to a USB pen drive or hard disk
- Copy the .iso file to a USB pen drive which has a `loopback.cfg` compatible boot manager installed

You will get an early shell before the Hurd console starts. Just press Ctrl+D to continue booting.

Network misconfigured? `showtrans`/`settrans` `/servers/socket/2` and/or `/servers/socket/26` and/or edit `/etc/resolv.conf`.

Change keyboard layout? Edit `/etc/console` and restart the Hurd console by Ctrl+Alt+Backspace.

Does not shutdown/restart? Use the Force, Luke (`-f`) after having unmounted (maybe also with Force)
all filesystems.

## Compiling from source

As written above, you will need to compile it on a Debian GNU/Hurd system, as Debian includes a patched
GNU Mach version with built-in ramdisk support.

First you need some build tools and programs to add to the rescue system:

    # apt install build-essential git xorriso fdisk zerofree

Then checkout this repo:

    # git clone https://github.com/schierlm/HurdRescue

First compile busybox

    # cd HurdRescue
    # ./build-busybox.sh

Then build the ext2 root filesystem image

    # ./build-rootfs.sh

Last, build the ISO file

    # ./build-iso.sh

You will find the ISO file as `build/HurdRescue.iso`.
