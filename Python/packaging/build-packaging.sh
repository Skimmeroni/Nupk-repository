#!/bin/sh -e

PRETTY_NAME=python:packaging
MAJOR=25
MINOR=0
PATCH=
VERSION=25.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/pypa/packaging/archive/$VERSION/python-packaging-$VERSION.tar.gz

gzip -cd python-packaging-$VERSION.tar.gz | tar -x
cd packaging-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-packaging@$VERSION.tar.gz"
doas rm -rf $DESTDIR
