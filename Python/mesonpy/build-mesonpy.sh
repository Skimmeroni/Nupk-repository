#!/bin/sh

set -eu

PRETTY_NAME=python:mesonpy
MAJOR=0
MINOR=18
PATCH=0
VERSION=0.18.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/mesonbuild/meson-python/archive/refs/tags/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd meson-python-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-mesonpy@$VERSION.tar.gz"
doas rm -rf $DESTDIR
