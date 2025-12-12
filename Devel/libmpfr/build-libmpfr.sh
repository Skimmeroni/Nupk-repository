#!/bin/sh

set -eu

PRETTY_NAME=mpfr
MAJOR=4
MINOR=2
PATCH=2
VERSION=4.2.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://www.mpfr.org/mpfr-current/mpfr-$VERSION.tar.xz

xz -cd mpfr-$VERSION.tar.xz | tar -x
cd mpfr-$VERSION

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share"
find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-libmpfr@$VERSION.tar.gz"
doas rm -rf $DESTDIR
