#!/bin/sh -e

PRETTY_NAME=cairo-graphics-library
MAJOR=1
MINOR=18
PATCH=4
VERSION=1.18.4

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://gitlab.freedesktop.org/cairo/cairo/-/archive/$VERSION/cairo-$VERSION.tar.gz

gzip -cd cairo-$VERSION.tar.gz | tar -x
cd cairo-$VERSION

muon setup \
	-D prefix=/usr \
	-D default_library=both \
	-D fontconfig=enabled \
	-D freetype=enabled \
	-D png=enabled \
	-D zlib=enabled \
	-D glib=enabled \
	-D gtk_doc=false \
	-D gtk2-utils=disabled \
	-D spectre=disabled \
	-D tests=disabled \
	-D tee=disabled \
	build

ninja -C build
muon -C build install -d $DESTDIR

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-cairo@$VERSION.tar.gz"
doas rm -rf $DESTDIR
