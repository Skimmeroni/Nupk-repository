#!/bin/sh -e

PRETTY_NAME=python:sympy
MAJOR=1
MINOR=14
PATCH=0
VERSION=1.14.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/sympy/sympy/archive/refs/tags/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd sympy-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-sympy@$VERSION.tar.gz"
doas rm -rf $DESTDIR
