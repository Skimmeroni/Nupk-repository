#!/bin/sh -e

PRETTY_NAME=python:pyyaml
MAJOR=6
MINOR=0
PATCH=3
VERSION=6.0.3

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://files.pythonhosted.org/packages/source/p/pyyaml/pyyaml-$VERSION.tar.gz

gzip -cd pyyaml-$VERSION.tar.gz | tar -x
cd pyyaml-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Python-pyyaml@$VERSION.tar.gz"
doas rm -rf $DESTDIR
