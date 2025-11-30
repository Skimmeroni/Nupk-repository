#!/bin/sh -e

PRETTY_NAME=expat
MAJOR=2
MINOR=7
PATCH=3
VERSION=2.7.3

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/libexpat/libexpat/releases/download/R\_$MAJOR\_$MINOR\_$PATCH/expat-$VERSION.tar.xz

xz -cd expat-$VERSION.tar.xz | tar -x
cd expat-$VERSION

./configure \
	--prefix=/usr \
	--without-xmlwf \
	--without-examples \
	--without-tests \
	--without-docbook

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share"
find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-expat@$VERSION.tar.gz"
doas rm -rf $DESTDIR
