#!/bin/sh

set -eu

PRETTY_NAME=python:jinja2
MAJOR=3
MINOR=1
PATCH=6
VERSION=3.1.6

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://files.pythonhosted.org/packages/source/j/jinja2/jinja2-$VERSION.tar.gz

gzip -cd jinja2-$VERSION.tar.gz | tar -x
cd jinja2-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-jinja2@$VERSION.tar.gz"
doas rm -rf $DESTDIR
