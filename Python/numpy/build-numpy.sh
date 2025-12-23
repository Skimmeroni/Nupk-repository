#!/bin/sh

set -eu

PRETTY_NAME=python:numpy
MAJOR=2
MINOR=4
PATCH=0
VERSION=2.4.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/numpy/numpy/releases/download/v$VERSION/numpy-$VERSION.tar.gz

gzip -cd numpy-$VERSION.tar.gz | tar -x
cd numpy-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-numpy@$VERSION.tar.gz"
doas rm -rf $DESTDIR
