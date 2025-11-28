#!/bin/sh -e

PRETTY_NAME=wayclip
MAJOR=0
MINOR=5
PATCH=
VERSION=0.5

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://git.sr.ht/~noocsharp/wayclip/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd wayclip-$VERSION

make PREFIX=/usr
make PREFIX=/usr DESTDIR=$DESTDIR install

strip --strip-unneeded $DESTDIR/usr/bin/waycopy
strip --strip-unneeded $DESTDIR/usr/bin/waypaste

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Wayland-wayclip@$VERSION.tar.gz"
doas rm -rf $DESTDIR
