#!/bin/sh

set -eu

PRETTY_NAME=gmp
MAJOR=6
MINOR=3
PATCH=0
VERSION=6.3.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://gmplib.org/download/gmp/gmp-$VERSION.tar.xz

xz -cd gmp-$VERSION.tar.xz | tar -x
cd gmp-$VERSION

./configure \
	--prefix=/usr \
	--localstatedir=/var/state/gmp \
	--enable-cxx \
	--enable-fat \
	--with-pic

make
make DESTDIR=$DESTDIR install

rm -rf "$DESTDIR/usr/share"
find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-libgmp@$VERSION.tar.gz"
doas rm -rf $DESTDIR
