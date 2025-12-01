#!/bin/sh

set -eu

PRETTY_NAME=libwebp
MAJOR=1
MINOR=6
PATCH=0
VERSION=1.6.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-$VERSION.tar.gz

gzip -cd libwebp-$VERSION.tar.gz | tar -x
cd libwebp-$VERSION

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static \
	--enable-libwebpmux \
	--enable-libwebpdemux \
	--enable-libwebpdecoder \
	--enable-swap-16bit-csp \
	--enable-near-lossless \
	--disable-libwebpextras \
	--disable-gl \
	--disable-sdl \
	--disable-png \
	--disable-jpeg \
	--disable-tiff \
	--disable-gif \
	--disable-wic

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-libwebp@$VERSION.tar.gz"
doas rm -rf $DESTDIR
