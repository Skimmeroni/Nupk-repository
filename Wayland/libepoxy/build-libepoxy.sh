#!/bin/sh

set -eu

PRETTY_NAME=libepoxy
MAJOR=1
MINOR=5
PATCH=10
VERSION=1.5.10

mkdir temporary-builddir
DESTDIR="$PWD/temporary-builddir"

curl --location --remote-name --skip-existing https://github.com/anholt/libepoxy/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd libepoxy-$VERSION

meson setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D strip=true \
	-D egl=yes \
	-D glx=no \
	-D docs=false \
	-D x11=false \
	-D tests=false \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-libepoxy@$VERSION.tar.gz"
doas rm -rf $DESTDIR
