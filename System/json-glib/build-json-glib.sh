#!/bin/sh

set -eu

PRETTY_NAME=json-glib
MAJOR=1
MINOR=10
PATCH=6
VERSION=1.10.6

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://download.gnome.org/sources/json-glib/$MAJOR.$MINOR/json-glib-$VERSION.tar.xz

xz -cd json-glib-$VERSION.tar.xz | tar -x
cd json-glib-$VERSION

meson setup \
	-D prefix=/usr \
	-D libexecdir=/usr/lib \
	-D default_library=both \
	-D buildtype=release \
	-D strip=true \
	-D tests=false \
	-D installed_tests=false \
	-D documentation=disabled \
	-D introspection=disabled \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-json-glib@$VERSION.tar.gz"
doas rm -rf $DESTDIR
