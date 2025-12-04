#!/bin/sh

set -eu

PRETTY_NAME=libgudev
MAJOR=238
MINOR=
PATCH=
VERSION=238

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://download.gnome.org/sources/libgudev/$VERSION/libgudev-$VERSION.tar.xz

xz -cd libgudev-$VERSION.tar.xz | tar -x
cd libgudev-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D wrap_mode=nofallback \
	-D gtk_doc=false \
	-D tests=disabled \
	-D vapi=disabled \
	-D introspection=disabled \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-libgudev@$VERSION.tar.gz"
doas rm -rf $DESTDIR
