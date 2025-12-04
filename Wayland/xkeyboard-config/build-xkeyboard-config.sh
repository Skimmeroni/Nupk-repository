#!/bin/sh

set -eu

PRETTY_NAME=xkeyboard-config
MAJOR=2
MINOR=46
PATCH=
VERSION=2.46

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://x.org/releases/individual/data/xkeyboard-config/xkeyboard-config-$VERSION.tar.xz

xz -cd xkeyboard-config-$VERSION.tar.xz | tar -x
cd xkeyboard-config-$VERSION

# Install to /usr/lib/pkgconfig instead of /usr/share/pkgconfig
patch -p1 < ../install-pkg-config-to-lib.patch

sed "s/subdir('po')//g" meson.build > meson.build.new
mv meson.build.new meson.build

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D compat-rules=true \
	build

meson compile -C build
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-xkeyboard-config@$VERSION.tar.gz"
doas rm -rf $DESTDIR
