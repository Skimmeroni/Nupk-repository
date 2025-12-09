#!/bin/sh

set -eu

PRETTY_NAME=python:versioneer
MAJOR=0
MINOR=29
PATCH=
VERSION=0.29

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/python-versioneer/python-versioneer/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x 
cd python-versioneer-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-versioneer@$VERSION.tar.gz"
doas rm -rf $DESTDIR
