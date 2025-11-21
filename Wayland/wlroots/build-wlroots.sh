#!/bin/sh -e

PRETTY_NAME=wlroots
MAJOR=0
MINOR=19
PATCH=2
VERSION=0.19.2

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://gitlab.freedesktop.org/wlroots/wlroots/-/archive/$VERSION/wlroots-$VERSION.tar.gz

gzip -cd wlroots-$VERSION.tar.gz | tar -x
cd wlroots-$VERSION

# TODO: vulkan?
muon setup \
	-D prefix=/usr \
	-D default_library=both \
	-D backends='libinput,drm' \
	-D renderers=gles2 \
	-D color-management=enabled \
	-D session=enabled \
	-D xcb-errors=disabled \
	-D xwayland=disabled \
	-D libliftoff=disabled \
	-D examples=false \
	build

ninja -C build
muon -C build install -d "$DESTDIR"

find "$DESTDIR/usr/lib" -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.so*' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../wlroots@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
