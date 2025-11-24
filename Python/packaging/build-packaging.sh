#!/bin/sh -e

PRETTY_NAME=python:packaging
MAJOR=25
MINOR=0
PATCH=
VERSION=25.0

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/pypa/packaging/archive/$VERSION/python-packaging-$VERSION.tar.gz

gzip -cd python-packaging-$VERSION.tar.gz | tar -x
cd packaging-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Python-packaging@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
