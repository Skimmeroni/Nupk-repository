#!/bin/sh

set -eu

PRETTY_NAME=pango
MAJOR=1
MINOR=57
PATCH=0
VERSION=1.57.0

mkdir temporary-builddir
DESTDIR="$PWD/temporary-builddir"

curl --location --remote-name --skip-existing https://download.gnome.org/sources/pango/$MAJOR.$MINOR/pango-$VERSION.tar.xz

xz -cd pango-$VERSION.tar.xz | tar -x
cd pango-$VERSION

rm -rf subprojects

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D strip=true \
	-D cairo=enabled \
	-D freetype=enabled \
	-D fontconfig=enabled \
	-D introspection=disabled \
	-D man-pages=false \
	-D documentation=false \
	-D build-testsuite=false \
	-D build-examples=false \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-pango@$VERSION.tar.gz"
doas rm -rf $DESTDIR
