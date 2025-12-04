#!/bin/sh

set -eu

PRETTY_NAME=wlsunset
MAJOR=0
MINOR=4
PATCH=0
VERSION=0.4.0

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://git.sr.ht/~kennylevinsen/wlsunset/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd wlsunset-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D strip=true \
	-D man-pages=enabled \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

install -Dm644 LICENSE "$DESTDIR/usr/share/LICENSES/wlsunset.license"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-wlsunset@$VERSION.tar.gz"
doas rm -rf $DESTDIR
