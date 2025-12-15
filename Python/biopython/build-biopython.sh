#!/bin/sh

set -eu

PRETTY_NAME=biopython
MAJOR=1
MINOR=86
PATCH=
VERSION=1.86

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://biopython.org/DIST/biopython-$VERSION.tar.gz

gzip -cd biopython-$VERSION.tar.gz | tar -x
cd biopython-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-biopython@$VERSION.tar.gz"
doas rm -rf $DESTDIR
