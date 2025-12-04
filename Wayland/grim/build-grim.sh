#!/bin/sh

set -eu

PRETTY_NAME=grim
MAJOR=1
MINOR=5
PATCH=0
VERSION=1.5.0

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://gitlab.freedesktop.org/emersion/grim/-/releases/v$VERSION/downloads/grim-$VERSION.tar.gz

gzip -cd grim-$VERSION.tar.gz | tar -x
cd grim-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D strip=true \
	-D bash-completions=false \
	-D fish-completions=false \
	-D jpeg=enabled \
	-D man-pages=enabled \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-grim@$VERSION.tar.gz"
doas rm -rf $DESTDIR
