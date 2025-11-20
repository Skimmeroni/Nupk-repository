#!/bin/sh -e

PRETTY_NAME=python:pyyaml
MAJOR=6
MINOR=0
PATCH=3
VERSION=6.0.3

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://files.pythonhosted.org/packages/source/p/pyyaml/pyyaml-$VERSION.tar.gz

gzip -cd pyyaml-$VERSION.tar.gz | tar -x
cd pyyaml-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../pyyaml@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
