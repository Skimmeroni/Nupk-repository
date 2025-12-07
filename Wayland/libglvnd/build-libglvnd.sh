#!/bin/sh

set -eu

PRETTY_NAME=libglvnd
MAJOR=1
MINOR=7
PATCH=0
VERSION=1.7.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://gitlab.freedesktop.org/glvnd/libglvnd/-/archive/v$VERSION/libglvnd-v$VERSION.tar.gz

gzip -cd libglvnd-v$VERSION.tar.gz | tar -x
cd libglvnd-v$VERSION

# -D default_library=both doesn't actually do anything
meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D strip=true \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-libglvnd@$VERSION.tar.gz"
doas rm -rf $DESTDIR
