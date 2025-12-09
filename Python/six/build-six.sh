#!/bin/sh

set -eu

PRETTY_NAME=python:six
MAJOR=1
MINOR=17
PATCH=0
VERSION=1.17.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/benjaminp/six/archive/refs/tags/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x 
cd six-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-six@$VERSION.tar.gz"
doas rm -rf $DESTDIR
