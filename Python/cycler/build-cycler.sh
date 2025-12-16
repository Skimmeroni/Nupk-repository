#!/bin/sh

set -eu

PRETTY_NAME=python:cycler
MAJOR=0
MINOR=12
PATCH=1
VERSION=0.12.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/matplotlib/cycler/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd cycler-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-cycler@$VERSION.tar.gz"
doas rm -rf $DESTDIR
