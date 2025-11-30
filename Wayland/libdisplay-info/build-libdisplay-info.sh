#!/bin/sh -e

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

rm -rf subprojects

muon setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	build

ninja -C build
muon -C build install -d "$DESTDIR"

find "$DESTDIR/usr/lib" -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.so*' -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/bin" -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-libdisplay-info@$VERSION.tar.gz"
doas rm -rf $DESTDIR
