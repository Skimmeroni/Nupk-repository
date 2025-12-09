#!/bin/sh

set -eu

PRETTY_NAME=setuptools-scm
MAJOR=9
MINOR=2
PATCH=2
VERSION=9.2.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/pypa/setuptools-scm/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x 
cd setuptools-scm-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-setuptools-scm@$VERSION.tar.gz"
doas rm -rf $DESTDIR
