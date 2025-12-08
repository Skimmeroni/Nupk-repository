#!/bin/sh

set -eu

PRETTY_NAME=python:pyproject-metadata
MAJOR=0
MINOR=10
PATCH=0
VERSION=0.10.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/pypa/pyproject-metadata/archive/refs/tags/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd pyproject-metadata-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-pyproject-metadata@$VERSION.tar.gz"
doas rm -rf $DESTDIR
