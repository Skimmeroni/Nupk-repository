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

meson setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D strip=true \
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

meson compile -C build
meson install -C build --destdir $DESTDIR

rm -rf "$DESTDIR/usr/share/gettext"
# Bash-completions aren't a toggable option, they are installed
# if bash is found in $PATH even if you don't want to
rm -rf "$DESTDIR/usr/share/bash-completion"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-glib@$VERSION.tar.gz"
doas rm -rf $DESTDIR
