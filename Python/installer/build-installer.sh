#!/bin/sh -e

PRETTY_NAME=python:installer
MAJOR=0
MINOR=7
PATCH=0
VERSION=0.7.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://files.pythonhosted.org/packages/py3/i/installer/installer-$VERSION-py3-none-any.whl

unzip installer-$VERSION-py3-none-any.whl

PYTHON_VERSION=$(python -c 'from sys import version_info as v; print(f"{v[0]}.{v[1]}")')
TARGET_DIRECTORY=$DESTDIR/usr/lib/python$PYTHON_VERSION/site-packages
mkdir -p $TARGET_DIRECTORY

python -m compileall installer
mv installer $TARGET_DIRECTORY

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > Python-installer@$VERSION.tar.gz"
doas rm -rf $DESTDIR
