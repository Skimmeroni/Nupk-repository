#!/bin/sh -e

PRETTY_NAME=python:markupsafe
MAJOR=3
MINOR=0
PATCH=3
VERSION=3.0.3

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/pallets/markupsafe/archive/refs/tags/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd markupsafe-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

find "$DESTDIR/usr/lib" -type f -name '*.so' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-markupsafe@$VERSION.tar.gz"
doas rm -rf $DESTDIR
