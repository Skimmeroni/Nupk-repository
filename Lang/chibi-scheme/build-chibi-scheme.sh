#!/bin/sh -e

PRETTY_NAME=chibi-scheme
MAJOR=0
MINOR=11
PATCH=0
VERSION=0.11.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing http://synthcode.com/scheme/chibi/chibi-scheme-$VERSION.tgz

tar -xf chibi-scheme-$VERSION.tgz
cd chibi-scheme-$VERSION

make PREFIX=/usr
make PREFIX=/usr DESTDIR=$DESTDIR install

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Lang-chibi-scheme@$VERSION.tar.gz"
doas rm -rf $DESTDIR
