#!/bin/sh

set -eu

PRETTY_NAME=python:bottleneck
MAJOR=1
MINOR=6
PATCH=0
VERSION=1.6.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing  https://github.com/pydata/bottleneck/archive/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd bottleneck-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-bottleneck@$VERSION.tar.gz"
doas rm -rf $DESTDIR
