#!/bin/sh

set -eu

PRETTY_NAME=libmpc-unclassified
MAJOR=1
MINOR=3
PATCH=1
VERSION=1.3.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/mpc/mpc-$VERSION.tar.gz

gzip -cd mpc-$VERSION.tar.gz | tar -x
cd mpc-$VERSION

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
doas sh -c "tar -cf - * | gzip > ../Devel-libmpc@$VERSION.tar.gz"
doas rm -rf $DESTDIR
