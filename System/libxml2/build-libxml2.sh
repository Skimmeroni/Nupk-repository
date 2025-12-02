#!/bin/sh

set -eu

PRETTY_NAME=libxml2
MAJOR=2
MINOR=15
PATCH=1
VERSION=2.15.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

# Only needed for at-spi2-core at the moment

curl --location --remote-name --skip-existing https://download.gnome.org/sources/libxml2/$MAJOR.$MINOR/libxml2-$VERSION.tar.xz

xz -cd libxml2-$VERSION.tar.xz | tar -x
cd libxml2-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D wrap_mode=nofallback \
	-D icu=disabled \
	-D readline=disabled \
	-D docs=disabled \
	-D python=disabled \
	-D legacy=disabled \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

find $DESTDIR/usr/bin       -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-libxml2@$VERSION.tar.gz"
doas rm -rf $DESTDIR
