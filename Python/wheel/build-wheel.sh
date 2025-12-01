#!/bin/sh

set -eu

PRETTY_NAME=python:wheel
MAJOR=0
MINOR=45
PATCH=1
VERSION=0.45.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://files.pythonhosted.org/packages/source/w/wheel/wheel-$VERSION.tar.gz

gzip -cd wheel-$VERSION.tar.gz | tar -x
cd wheel-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-wheel@$VERSION.tar.gz"
doas rm -rf $DESTDIR
