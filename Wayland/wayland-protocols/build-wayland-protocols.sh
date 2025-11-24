#!/bin/sh -e

PRETTY_NAME=wayland-protocols
MAJOR=1
MINOR=45
PATCH=
VERSION=1.45

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://gitlab.freedesktop.org/wayland/wayland-protocols/-/releases/$VERSION/downloads/wayland-protocols-$VERSION.tar.xz

xz -cd wayland-protocols-$VERSION.tar.xz | tar -x
cd wayland-protocols-$VERSION

muon setup \
	-D prefix=/usr \
	-D datadir=lib \
	-D buildtype=release \
	-D tests=false \
	build

ninja -C build
muon -C build install -d "$DESTDIR"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Wayland-wayland-protocols@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
