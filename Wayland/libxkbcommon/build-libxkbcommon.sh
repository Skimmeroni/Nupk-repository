#!/bin/sh

set -eu

PRETTY_NAME=libxkbcommon
MAJOR=1
MINOR=13
PATCH=0
VERSION=1.13.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/xkbcommon/libxkbcommon/archive/refs/tags/xkbcommon-$VERSION.tar.gz

gzip -cd xkbcommon-$VERSION.tar.gz | tar -x
cd libxkbcommon-xkbcommon-$VERSION

meson setup \
	-D prefix=/usr \
	-D libdir=/usr/lib \
	-D libexecdir=/usr/lib \
	-D buildtype=release \
	-D default_library=both \
	-D strip=true \
	-D enable-docs=false \
	-D enable-tools=false \
	-D enable-wayland=true \
	-D enable-x11=false \
	-D enable-bash-completion=false \
	-D enable-xkbregistry=false \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-libxkbcommon@$VERSION.tar.gz"
doas rm -rf $DESTDIR
