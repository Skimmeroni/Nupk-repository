#!/bin/sh -e

PRETTY_NAME=libtool
MAJOR=2
MINOR=5
PATCH=4
VERSION=2.5.4

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/libtool/libtool-$VERSION.tar.xz

xz -cd libtool-$VERSION.tar.xz | tar -x
cd libtool-$VERSION

./configure --prefix=/usr

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/info"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../libtool@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
