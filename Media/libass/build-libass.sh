#!/bin/sh

set -eu

PRETTY_NAME=libass
MAJOR=0
MINOR=17
PATCH=4
VERSION=0.17.4

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/libass/libass/releases/download/$VERSION/libass-$VERSION.tar.xz

xz -cd libass-$VERSION.tar.xz | tar -x
cd libass-$VERSION

# Taken from Gentoo
./configure \
	--prefix=/usr \
	--enable-fontconfig \
	--with-pic \
	--disable-libunibreak \
	--disable-test \
	--disable-require-system-font-provider

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -name '*.la' -type f -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-libass@$VERSION.tar.gz"
doas rm -rf $DESTDIR
