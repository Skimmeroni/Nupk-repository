#!/bin/sh

set -eu

PRETTY_NAME=libogg
MAJOR=1
MINOR=3
PATCH=6
VERSION=1.3.6

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/xiph/ogg/releases/download/v$VERSION/libogg-$VERSION.tar.xz

xz -cd libogg-$VERSION.tar.xz | tar -x
cd libogg-$VERSION

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static

make -C src
make DESTDIR=$DESTDIR -C include install
make DESTDIR=$DESTDIR -C src install-strip
make DESTDIR=$DESTDIR install-m4dataDATA
make DESTDIR=$DESTDIR install-pkgconfigDATA

find $DESTDIR -type f -name '*.la' -delete 

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-libogg@$VERSION.tar.gz"
doas rm -rf $DESTDIR
