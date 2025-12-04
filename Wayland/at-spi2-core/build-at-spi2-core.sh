#!/bin/sh

set -eu

PRETTY_NAME=at-spi2-core
MAJOR=2
MINOR=58
PATCH=2
VERSION=2.58.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://download.gnome.org/sources/at-spi2-core/$MAJOR.$MINOR/at-spi2-core-$VERSION.tar.xz

xz -cd at-spi2-core-$VERSION.tar.xz | tar -x
cd at-spi2-core-$VERSION

meson setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D strip=true \
	-D default_bus=dbus-daemon \
	-D docs=false \
	-D introspection=disabled \
	-D use_systemd=false \
	-D gtk2_atk_adaptor=false \
	-D x11=disabled \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-at-spi2-core@$VERSION.tar.gz"
doas rm -rf $DESTDIR
