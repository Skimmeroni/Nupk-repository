#!/bin/sh

set -eu

PRETTY_NAME=wayland
MAJOR=1
MINOR=24
PATCH=0
VERSION=1.24.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://gitlab.freedesktop.org/wayland/wayland/-/releases/$VERSION/downloads/wayland-$VERSION.tar.xz

xz -cd wayland-$VERSION.tar.xz | tar -x
cd wayland-$VERSION

muon setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D tests=false \
	-D documentation=false \
	-D dtd_validation=false \
	build

ninja -C build
muon -C build install -d "$DESTDIR"

find "$DESTDIR/usr/lib" -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.so*' -exec strip --strip-unneeded {} \;
strip --strip-unneeded "$DESTDIR/usr/bin/wayland-scanner"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-wayland@$VERSION.tar.gz"
doas rm -rf $DESTDIR
