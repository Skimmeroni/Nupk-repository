#!/bin/sh -e

PRETTY_NAME=grim
MAJOR=1
MINOR=5
PATCH=0
VERSION=1.5.0

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://gitlab.freedesktop.org/emersion/grim/-/releases/v$VERSION/downloads/grim-$VERSION.tar.gz

gzip -cd grim-$VERSION.tar.gz | tar -x
cd grim-$VERSION

muon setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D bash-completions=false \
	-D fish-completions=false \
	-D jpeg=enabled \
	-D man-pages=enabled \
	build

ninja -C build
muon -C build install -d $DESTDIR

strip --strip-unneeded $DESTDIR/usr/bin/grim

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-grim@$VERSION.tar.gz"
doas rm -rf $DESTDIR
