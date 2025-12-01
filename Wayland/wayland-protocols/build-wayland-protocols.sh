#!/bin/sh

set -eu

PRETTY_NAME=wayland-protocols
MAJOR=1
MINOR=46
PATCH=
VERSION=1.46

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/$VERSION/downloads/wayland-protocols-$VERSION.tar.xz

xz -cd wayland-protocols-$VERSION.tar.xz | tar -x
cd wayland-protocols-$VERSION

muon setup \
	-D prefix=/usr \
	-D datadir=lib \
	-D buildtype=release \
	-D tests=false \
	build

ninja -C build
muon -C build install -d "$DESTDIR"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-wayland-protocols@$VERSION.tar.gz"
doas rm -rf $DESTDIR
