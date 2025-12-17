#!/bin/sh

set -eu

PRETTY_NAME=python:fonttools
MAJOR=4
MINOR=61
PATCH=1
VERSION=4.61.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/fonttools/fonttools/archive/refs/tags/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd fonttools-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

find "$DESTDIR/usr/lib" -type f -name '*.so' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-fonttools@$VERSION.tar.gz"
doas rm -rf $DESTDIR
