#!/bin/sh

set -eu

PRETTY_NAME=python:numexpr
MAJOR=2
MINOR=14
PATCH=1
VERSION=2.14.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing  https://github.com/pydata/numexpr/archive/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd numexpr-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-numexpr@$VERSION.tar.gz"
doas rm -rf $DESTDIR
