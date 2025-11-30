#!/bin/sh -e

PRETTY_NAME=libressl
MAJOR=4
MINOR=2
PATCH=1
VERSION=4.2.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$VERSION.tar.gz

gzip -cd libressl-$VERSION.tar.gz | tar -x
cd libressl-$VERSION

./configure \
	--prefix=/usr \
	--enable-static \
	--disable-tests

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/man"
find $DESTDIR -type f -name '*.la' -delete

install -Dm644 COPYING "$DESTDIR/usr/share/LICENSES/libressl.license"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-libressl@$VERSION.tar.gz"
doas rm -rf $DESTDIR
