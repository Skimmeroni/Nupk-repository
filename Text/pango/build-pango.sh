#!/bin/sh -e

PRETTY_NAME=pango
MAJOR=1
MINOR=57
PATCH=0
VERSION=1.57.0

mkdir temporary-builddir
DESTDIR="$PWD/temporary-builddir"

curl --location --remote-name --skip-existing https://download.gnome.org/sources/pango/$MAJOR.$MINOR/pango-$VERSION.tar.xz

xz -cd pango-$VERSION.tar.xz | tar -x
cd pango-$VERSION

rm -rf subprojects

muon setup \
	-D prefix=/usr \
	-D default_library=both \
	-D cairo=enabled \
	-D freetype=enabled \
	-D fontconfig=enabled \
	-D introspection=disabled \
	-D man-pages=false \
	-D documentation=false \
	-D build-testsuite=false \
	-D build-examples=false \
	build

ninja -C build
muon -C build install -d $DESTDIR

find $DESTDIR/usr/bin       -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Text-pango@$VERSION.tar.gz"
doas rm -rf $DESTDIR
