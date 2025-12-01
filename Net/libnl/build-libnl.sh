#!/bin/sh

set -eu

PRETTY_NAME=libnl
MAJOR=3
MINOR=11
PATCH=0
VERSION=3.11.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/thom311/libnl/releases/download/libnl$MAJOR\_$MINOR\_$PATCH/libnl-$VERSION.tar.gz

gzip -cd libnl-$VERSION.tar.gz | tar -x
cd libnl-$VERSION

./configure \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-cli \
	--disable-debug

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Net-libnl@$VERSION.tar.gz"
doas rm -rf $DESTDIR
