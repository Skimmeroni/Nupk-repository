#!/bin/sh

set -eu

PRETTY_NAME=pixman
MAJOR=0
MINOR=46
PATCH=4
VERSION=0.46.4

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://x.org/releases/individual/lib/pixman-$VERSION.tar.xz

xz -cd pixman-$VERSION.tar.xz | tar -x
cd pixman-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D strip=true \
	-D gtk=disabled \
	-D tests=disabled \
	-D libpng=disabled \
	-D demos=disabled \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-pixman@$VERSION.tar.gz"
doas rm -rf $DESTDIR
