#!/bin/sh -e

PRETTY_NAME=chibi-scheme
MAJOR=0
MINOR=11
PATCH=0
VERSION=0.11.0

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing http://synthcode.com/scheme/chibi/chibi-scheme-$VERSION.tgz

tar -xf chibi-scheme-$VERSION.tgz
cd chibi-scheme-$VERSION

make PREFIX=/usr
make PREFIX=/usr DESTDIR=$DESTDIR install

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../chibi-scheme@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
