#!/bin/sh

set -eu

PRETTY_NAME=e2fsprogs
MAJOR=1
MINOR=47
PATCH=3
VERSION=1.47.3

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v$VERSION/e2fsprogs-$VERSION.tar.xz

xz -cd e2fsprogs-$VERSION.tar.xz | tar -x
cd e2fsprogs-$VERSION

./configure \
	--prefix=/usr \
	--sbindir=/usr/bin \
	--sysconfdir=/etc \
	--enable-symlink-install \
	--disable-libuuid \
	--disable-libblkid \
	--disable-nls \
	--disable-uuidd \
	--disable-elf-shlibs \
	--disable-tls \
	--disable-lto \
	--disable-fuse2fs \
	--disable-e2initrd-helper \
	--with-pthread \
	--without-systemd-unit-dir \
	--without-udev-rules-dir
	
make
make DESTDIR=$DESTDIR install-strip

rmdir "$DESTDIR/usr/share/info"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Fs-e2fsprogs@$VERSION.tar.gz"
doas rm -rf $DESTDIR
