#!/bin/sh

set -eu

PRETTY_NAME=python:pandas
MAJOR=2
MINOR=3
PATCH=3
VERSION=2.3.3

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://www.github.com/pandas-dev/pandas/releases/download/v$VERSION/pandas-$VERSION.tar.gz

gzip -cd pandas-$VERSION.tar.gz | tar -x
cd pandas-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D strip=true \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Python-pandas@$VERSION.tar.gz"
doas rm -rf $DESTDIR
