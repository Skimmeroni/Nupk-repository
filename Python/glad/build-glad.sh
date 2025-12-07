#!/bin/sh

set -eu

PRETTY_NAME=python:glad
MAJOR=2
MINOR=0
PATCH=8
VERSION=2.0.8

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/Dav1dde/glad/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd glad-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-glad@$VERSION.tar.gz"
doas rm -rf $DESTDIR
