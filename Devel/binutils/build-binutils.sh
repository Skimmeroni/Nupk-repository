#!/bin/sh

set -eu

PRETTY_NAME=binutils
MAJOR=2
MINOR=45
PATCH=1
VERSION=2.45.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/binutils/binutils-$VERSION.tar.xz

tar -xf binutils-$VERSION.tar.xz
cd binutils-$VERSION

./configure \
	--prefix=/usr \
	--enable-ld=yes \
	--enable-plugins \
	--enable-lto \
	--disable-jansson \
	--disable-multilib \
	--disable-werror \
	--disable-nls \
	--disable-gprofng \
	--disable-compressed-debug-sessions

make configure-host
make tooldir=/usr
make tooldir=/usr DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/info"
find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-binutils@$VERSION.tar.gz"
doas rm -rf $DESTDIR
