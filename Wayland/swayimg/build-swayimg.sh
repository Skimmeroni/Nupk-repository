#!/bin/sh

set -eu

PRETTY_NAME=swayimg
MAJOR=4
MINOR=6
PATCH=
VERSION=4.6

mkdir temporary-builddir
DESTDIR="$PWD/temporary-builddir"

curl --location --remote-name --skip-existing https://github.com/artemsen/swayimg/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd swayimg-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D strip=true \
	-D gif=enabled \
	-D jpeg=enabled \
	-D png=enabled \
	-D tiff=enabled \
	-D webp=enabled \
	-D exif=disabled \
	-D heif=disabled \
	-D jxl=disabled \
	-D svg=enabled \
	-D bash=disabled \
	-D zsh=disabled \
	-D man=true \
	-D desktop=true \
	build 

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

install -Dm644 LICENSE "$DESTDIR/usr/share/LICENSES/swayimg.license" 
install -Dm644 extra/swayimgrc "$DESTDIR/etc/xdg/swayimg/config"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-swayimg@$VERSION.tar.gz"
doas rm -rf $DESTDIR
