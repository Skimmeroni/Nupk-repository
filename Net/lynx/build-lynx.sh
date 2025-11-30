#!/bin/sh -e

PRETTY_NAME=lynx
MAJOR=2
MINOR=9
PATCH=2
VERSION=2.9.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://invisible-mirror.net/archives/lynx/tarballs/lynx$VERSION.tar.bz2

bzip2 -cd lynx$VERSION.tar.bz2 | tar -x
cd lynx$VERSION

./configure \
	--prefix=/usr \
	--sysconfdir=/etc/lynx \
	--disable-dired \
	--without-brotli \
	--without-bzlib \
	--without-zlib \
	--with-ssl

make
make DESTDIR=$DESTDIR install

strip --strip-unneeded $DESTDIR/usr/bin/lynx

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Net-lynx@$VERSION.tar.gz"
doas rm -rf $DESTDIR
