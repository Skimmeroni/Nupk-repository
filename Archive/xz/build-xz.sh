#!/bin/sh

set -eu

PRETTY_NAME=xz
MAJOR=5
MINOR=8
PATCH=1
VERSION=5.8.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://tukaani.org/xz/xz-$VERSION.tar.gz

gzip -cd xz-$VERSION.tar.gz | tar -x
cd xz-$VERSION

./configure \
	--prefix=/usr \
	--disable-doc \
	--disable-nls

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Archive-xz@$VERSION.tar.gz"
doas rm -rf $DESTDIR
