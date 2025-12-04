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

muon setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D documentation=disabled \
	-D tests=disabled \
	build

ninja -C build
muon -C build install -d $DESTDIR

find "$DESTDIR/usr/bin" -type f -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.so*' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-libwacom@$VERSION.tar.gz"
doas rm -rf $DESTDIR
