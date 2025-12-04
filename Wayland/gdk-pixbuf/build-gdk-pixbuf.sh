#!/bin/sh

set -eu

PRETTY_NAME=gdk-pixbuf
MAJOR=2
MINOR=44
PATCH=4
VERSION=2.44.4

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://download.gnome.org/sources/gdk-pixbuf/$MAJOR.$MINOR/gdk-pixbuf-$VERSION.tar.xz
 
xz -cd gdk-pixbuf-$VERSION.tar.xz | tar -x
cd gdk-pixbuf-$VERSION

# Disable preemptive caching in any shape or form
# Might not be necessary now that we use meson
print '#!/usr/bin/env python3' > build-aux/post-install.py
patch -p1 < ../dont-test-loaders-cache.patch

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D wrap_mode=nofallback \
	-D strip=true \
	-D png=enabled \
	-D jpeg=enabled \
	-D tiff=enabled \
	-D gif=enabled \
	-D builtin_loaders=all \
	-D tests=false \
	-D installed_tests=false \
	-D documentation=false \
	-D man=false \
	-D gio_sniffing=false \
	-D glycin=disabled \
	-D introspection=disabled \
	-D thumbnailer=disabled \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-gdk-pixbuf@$VERSION.tar.gz"
doas rm -rf $DESTDIR

printf "\033[1mRemember to generate the loaders cache!\033[0m\n"
# doas mkdir -p /usr/lib/gdk-pixbuf-2.0/2.10.0
# doas gdk-pixbuf-query-loaders --update-cache
