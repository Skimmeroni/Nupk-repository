#!/bin/sh -e

PRETTY_NAME=libudev-zero
MAJOR=1
MINOR=0
PATCH=3
VERSION=1.0.3

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/illiliti/libudev-zero/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd libudev-zero-$VERSION

make PREFIX=/usr
make PREFIX=/usr DESTDIR=$DESTDIR install

find "$DESTDIR/usr/lib" -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.so*' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../System-libudev-zero@$VERSION.tar.gz"
doas rm -rf $DESTDIR
