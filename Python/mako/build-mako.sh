#!/bin/sh

set -eu

PRETTY_NAME=python:mako
MAJOR=1
MINOR=3
PATCH=10
VERSION=1.3.10

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/sqlalchemy/mako/archive/refs/tags/rel_${MAJOR}_${MINOR}_${PATCH}.tar.gz

gzip -cd rel_${MAJOR}_${MINOR}_${PATCH}.tar.gz | tar -x
cd mako-rel_${MAJOR}_${MINOR}_${PATCH}

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-mako@$VERSION.tar.gz"
doas rm -rf $DESTDIR
