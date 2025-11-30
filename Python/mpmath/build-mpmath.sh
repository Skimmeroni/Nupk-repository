#!/bin/sh -e

PRETTY_NAME=python:mpmath
MAJOR=1
MINOR=3
PATCH=0
VERSION=1.3.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/mpmath/mpmath/archive/refs/tags/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd mpmath-$VERSION

python setup.py install --prefix=/usr --root=$DESTDIR

find "$DESTDIR/usr/lib" -type f -name '*.so' -exec strip --strip-unneeded {} \;

PYTHON_VERSION=$(python -c 'from sys import version_info as v; print(f"{v[0]}.{v[1]}")')
rm -rf $DESTDIR/usr/lib/python$PYTHON_VERSION/site-packages/mpmath/tests

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-mpmath@$VERSION.tar.gz"
doas rm -rf $DESTDIR
