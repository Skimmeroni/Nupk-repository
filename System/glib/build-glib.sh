#!/bin/sh

set -eu

PRETTY_NAME=glib
MAJOR=2
MINOR=86
PATCH=2
VERSION=2.86.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://download.gnome.org/sources/glib/$MAJOR.$MINOR/glib-$VERSION.tar.xz

xz -cd glib-$VERSION.tar.xz | tar -x
cd glib-$VERSION

# Prevents muon from failing
rm subprojects/gvdb.wrap

muon setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D libmount=disabled \
	-D sysprof=disabled \
	-D man-pages=disabled \
	-D documentation=false \
	-D tests=false \
	-D installed_tests=false \
	-D nls=disabled \
	-D libelf=disabled \
	-D introspection=disabled \
	build

ninja -C build
muon -C build install -d $DESTDIR

rm -rf $DESTDIR/usr/share/gettext

#find $DESTDIR/usr/bin      -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-glib@$VERSION.tar.gz"
doas rm -rf $DESTDIR
