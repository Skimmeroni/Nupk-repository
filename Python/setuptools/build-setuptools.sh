#!/bin/sh

set -eu

PRETTY_NAME=python:setuptools
MAJOR=80
MINOR=9
PATCH=0
VERSION=80.9.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/pypa/setuptools/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd setuptools-$VERSION

# TODO: unvendor (sic.) dependencies
python setup.py install --prefix=/usr --root=$DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-setuptools@$VERSION.tar.gz"
doas rm -rf $DESTDIR
