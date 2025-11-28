#!/bin/sh -e

PRETTY_NAME=fakesteak
MAJOR=0
MINOR=2
PATCH=4
VERSION=0.2.4

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/domsson/fakesteak/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd fakesteak-$VERSION

make
install -Dm755 bin/fakesteak "$DESTDIR/usr/bin/fakesteak"
strip --strip-unneeded "$DESTDIR/usr/bin/fakesteak"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Misc-fakesteak@$VERSION.tar.gz"
doas rm -rf $DESTDIR
