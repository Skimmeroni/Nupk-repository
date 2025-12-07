#!/bin/sh

set -eu

PRETTY_NAME=mako-notifier
MAJOR=1
MINOR=10
PATCH=0
VERSION=1.10.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/emersion/mako/releases/download/v$VERSION/mako-$VERSION.tar.gz

gzip -cd mako-$VERSION.tar.gz | tar -x
cd mako-$VERSION

meson setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D strip=true \
	-D wrap_mode=nofallback \
	-D sd-bus-provider=basu \
	-D man-pages=enabled \
	-D icons=enabled \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-mako@$VERSION.tar.gz"
doas rm -rf $DESTDIR
