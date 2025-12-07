#!/bin/sh

set -eu

PRETTY_NAME=libdisplay-info
MAJOR=0
MINOR=3
PATCH=0
VERSION=0.3.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://gitlab.freedesktop.org/emersion/libdisplay-info/-/archive/$VERSION/libdisplay-info-$VERSION.tar.gz

gzip -cd libdisplay-info-$VERSION.tar.gz | tar -x
cd libdisplay-info-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D wrap_mode=nofallback \
	-D strip=true \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-libdisplay-info@$VERSION.tar.gz"
doas rm -rf $DESTDIR
