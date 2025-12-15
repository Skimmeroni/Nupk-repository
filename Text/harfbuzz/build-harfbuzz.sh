#!/bin/sh

set -eu

PRETTY_NAME=harfbuzz
MAJOR=12
MINOR=2
PATCH=0
VERSION=12.2.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/harfbuzz/harfbuzz/releases/download/$VERSION/harfbuzz-$VERSION.tar.xz

xz -cd harfbuzz-$VERSION.tar.xz | tar -x
cd harfbuzz-$VERSION

meson setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D libdir=/usr/lib \
	-D strip=true \
	-D cairo=enabled \
	-D freetype=enabled \
	-D glib=enabled \
	-D gobject=enabled \
	-D icu=enabled \
	-D benchmark=disabled \
	-D chafa=disabled \
	-D coretext=disabled \
	-D introspection=disabled \
	-D tests=disabled \
	-D wasm=disabled \
	-D fontations=disabled \
	-D docs=disabled \
	-D utilities=disabled \
	build

meson compile -C build --verbose --jobs 1
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-harfbuzz@$VERSION.tar.gz"
doas rm -rf $DESTDIR
