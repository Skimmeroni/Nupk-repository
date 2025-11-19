#!/bin/sh -e

PRETTY_NAME=python:wheel
MAJOR=0
MINOR=45
PATCH=1
VERSION=0.45.1

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://files.pythonhosted.org/packages/source/w/wheel/wheel-$VERSION.tar.gz

gzip -cd wheel-$VERSION.tar.gz | tar -x
cd wheel-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../wheel@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
