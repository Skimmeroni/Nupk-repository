#!/bin/sh

set -eu

PRETTY_NAME=wlroots
MAJOR=0
MINOR=19
PATCH=2
VERSION=0.19.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://gitlab.freedesktop.org/wlroots/wlroots/-/archive/$VERSION/wlroots-$VERSION.tar.gz

gzip -cd wlroots-$VERSION.tar.gz | tar -x
cd wlroots-$VERSION

# TODO: vulkan?
meson setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D strip=true \
	-D backends='libinput,drm' \
	-D renderers=gles2 \
	-D color-management=enabled \
	-D session=enabled \
	-D xcb-errors=disabled \
	-D xwayland=disabled \
	-D libliftoff=disabled \
	-D examples=false \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-wlroots@$VERSION.tar.gz"
doas rm -rf $DESTDIR
