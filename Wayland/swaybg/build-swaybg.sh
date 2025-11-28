#!/bin/sh -e

PRETTY_NAME=swaybg
MAJOR=1
MINOR=2
PATCH=1
VERSION=1.2.1

mkdir temporary-builddir
DESTDIR="$PWD/temporary-builddir"

curl --location --remote-name --skip-existing https://github.com/swaywm/swaybg/archive/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd swaybg-$VERSION

# TODO: gdk-pixbuf has to be installed anyway
muon setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D man-pages=enabled \
	-D gdk-pixbuf=disabled \
	build

ninja -C build
muon -C build install -d $DESTDIR

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Wayland-swaybg@$VERSION.tar.gz"
doas rm -rf $DESTDIR
