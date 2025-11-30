#!/bin/sh -e

PRETTY_NAME=python:cython
MAJOR=3
MINOR=2
PATCH=2
VERSION=3.2.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/cython/cython/releases/download/$VERSION/Cython-$VERSION.tar.gz

gzip -cd Cython-$VERSION.tar.gz | tar -x
cd cython-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

find "$DESTDIR/usr/lib" -type f -name '*.so' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Python-cython@$VERSION.tar.gz"
doas rm -rf $DESTDIR
