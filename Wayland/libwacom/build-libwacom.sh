#!/bin/sh

set -eu

PRETTY_NAME=libwacom
MAJOR=2
MINOR=17
PATCH=0
VERSION=2.17.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/linuxwacom/libwacom/releases/download/libwacom-$VERSION/libwacom-$VERSION.tar.xz

xz -cd libwacom-$VERSION.tar.xz | tar -x
cd libwacom-$VERSION

meson setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D strip=true \
	-D documentation=disabled \
	-D tests=disabled \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-libwacom@$VERSION.tar.gz"
doas rm -rf $DESTDIR
