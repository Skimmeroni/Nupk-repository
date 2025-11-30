#!/bin/sh -e

PRETTY_NAME=mtdev
MAJOR=1
MINOR=1
PATCH=7
VERSION=1.1.7

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://bitmath.org/code/mtdev/mtdev-$VERSION.tar.bz2

bzip2 -cd mtdev-$VERSION.tar.bz2 | tar -x
cd mtdev-$VERSION

./configure --prefix=/usr

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-mtdev@$VERSION.tar.gz"
doas rm -rf $DESTDIR
