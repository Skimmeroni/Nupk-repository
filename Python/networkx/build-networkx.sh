#!/bin/sh

set -eu

PRETTY_NAME=python:networkx
MAJOR=3
MINOR=6
PATCH=1
VERSION=3.6.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/networkx/networkx/archive/refs/tags/networkx-$VERSION.tar.gz

gzip -cd networkx-$VERSION.tar.gz | tar -x
cd networkx-networkx-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-networkx@$VERSION.tar.gz"
doas rm -rf $DESTDIR
