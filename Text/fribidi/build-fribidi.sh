#!/bin/sh

set -eu

PRETTY_NAME=fribidi
MAJOR=1
MINOR=0
PATCH=16
VERSION=1.0.16

mkdir temporary-builddir
DESTDIR="$PWD/temporary-builddir"

curl --location --remote-name --skip-existing https://github.com/fribidi/fribidi/releases/download/v$VERSION/fribidi-$VERSION.tar.xz

xz -cd fribidi-$VERSION.tar.xz | tar -x
cd fribidi-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D strip=true \
	-D bin=false \
	-D docs=false \
	-D tests=false \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-fribidi@$VERSION.tar.gz"
doas rm -rf $DESTDIR
