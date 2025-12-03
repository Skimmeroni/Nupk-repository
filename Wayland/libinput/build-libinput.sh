#!/bin/sh

set -eu

PRETTY_NAME=libinput
MAJOR=1
MINOR=30
PATCH=0
VERSION=1.30.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://gitlab.freedesktop.org/libinput/libinput/-/archive/$VERSION/libinput-$VERSION.tar.gz

gzip -cd libinput-$VERSION.tar.gz | tar -x
cd libinput-$VERSION

# -D default_library=both doesn't actually do anything
muon setup \
	-D prefix=/usr \
	-D sysconfdir=/etc \
	-D mandir=/usr/share/man \
	-D libexecdir=/usr/lib \
	-D default_library=both \
	-D buildtype=release \
	-D debug-gui=false \
	-D documentation=false \
	-D tests=false \
	-D zshcompletiondir=no \
	build

ninja -C build
muon -C build install -d "$DESTDIR"

strip --strip-unneeded "$DESTDIR/usr/bin/libinput"
find "$DESTDIR/usr/lib" -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.so*' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-libinput@$VERSION.tar.gz"
doas rm -rf $DESTDIR
