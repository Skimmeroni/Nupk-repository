#!/bin/sh -e

PRETTY_NAME=fakesteak
MAJOR=0
MINOR=2
PATCH=4
VERSION=0.2.4

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://github.com/domsson/fakesteak/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd fakesteak-$VERSION

make
install -Dm755 -t "$DESTDIR/usr/bin" bin/fakesteak

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../fakesteak@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
