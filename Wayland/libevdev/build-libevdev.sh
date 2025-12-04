#!/bin/sh

set -eu

PRETTY_NAME=libevdev
MAJOR=1
MINOR=13
PATCH=6
VERSION=1.13.6

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://freedesktop.org/software/libevdev/libevdev-$VERSION.tar.xz

xz -cd libevdev-$VERSION.tar.xz | tar -x
cd libevdev-$VERSION

meson setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D strip=true \
	-D documentation=disabled \
	-D tests=disabled \
	-D tools=disabled \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

rm -rf "$DESTDIR/usr/share"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-libevdev@$VERSION.tar.gz"
doas rm -rf $DESTDIR
