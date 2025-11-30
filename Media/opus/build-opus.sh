#!/bin/sh -e

PRETTY_NAME=opus
MAJOR=1
MINOR=5
PATCH=2
VERSION=1.5.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://downloads.xiph.org/releases/opus/opus-$VERSION.tar.gz

gzip -cd opus-$VERSION.tar.gz | tar -x
cd opus-$VERSION

./configure \
	--prefix=/usr \
	--enable-custom-modes \
	--disable-doc \
	--disable-extra-programs

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-opus@$VERSION.tar.gz"
doas rm -rf $DESTDIR
