#!/bin/sh -e

PRETTY_NAME=zlib
MAJOR=1
MINOR=3
PATCH=1
VERSION=1.3.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://zlib.net/fossils/zlib-$VERSION.tar.gz

gzip -cd zlib-$VERSION.tar.gz | tar -x
cd zlib-$VERSION

./configure --prefix=/usr

make
make DESTDIR=$DESTDIR install

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

rm -rf "$DESTDIR/usr/share"
find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Archive-zlib@$VERSION.tar.gz"
doas rm -rf $DESTDIR
