#!/bin/sh -e

PRETTY_NAME=slurp
MAJOR=1
MINOR=5
PATCH=0
VERSION=1.5.0

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://github.com/emersion/slurp/releases/download/v$VERSION/slurp-$VERSION.tar.gz

gzip -cd slurp-$VERSION.tar.gz | tar -x
cd slurp-$VERSION

muon setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D man-pages=enabled \
	build

ninja -C build
muon -C build install -d $DESTDIR

strip --strip-unneeded $DESTDIR/usr/bin/slurp

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-slurp@$VERSION.tar.gz"
doas rm -rf $DESTDIR
