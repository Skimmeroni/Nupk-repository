#!/bin/sh

set -eu

PRETTY_NAME=file
MAJOR=5
MINOR=46
PATCH=
VERSION=5.46

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://astron.com/pub/file/file-$VERSION.tar.gz

gzip -cd file-$VERSION.tar.gz | tar -x
cd file-$VERSION

./configure \
	--prefix=/usr \
	--enable-fsect-man5 \
	--enable-static \
	--disable-bzlib \
	--disable-lzlib \
	--disable-xzlib \
	--disable-zlib \
	--disable-libseccomp

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/man/man3"
find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-file@$VERSION.tar.gz"
doas rm -rf $DESTDIR
