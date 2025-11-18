#!/bin/sh -e

PRETTY_NAME=libressl
MAJOR=4
MINOR=2
PATCH=1
VERSION=4.2.1

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

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
doas sh -c "tar -zcC $DESTDIR . | gzip > ../libressl@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
