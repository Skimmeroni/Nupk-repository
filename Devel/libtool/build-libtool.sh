#!/bin/sh -e

PRETTY_NAME=libtool
MAJOR=2
MINOR=5
PATCH=4
VERSION=2.5.4

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/libtool/libtool-$VERSION.tar.xz

xz -cd libtool-$VERSION.tar.xz | tar -x
cd libtool-$VERSION

./configure --prefix=/usr

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/info"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-libtool@$VERSION.tar.gz"
doas rm -rf $DESTDIR
