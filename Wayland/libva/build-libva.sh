#!/bin/sh -e

PRETTY_NAME=libva
MAJOR=2
MINOR=22
PATCH=0
VERSION=2.22.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/intel/libva/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd libva-$VERSION

# default_library=both doesn't do anything
muon setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D enable_docs=false \
	-D disable_drm=false \
	-D with_x11=no \
	-D with_glx=no \
	-D with_wayland=yes \
	build

ninja -C build
muon -C build install -d "$DESTDIR"

find "$DESTDIR/usr/lib" -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.so*' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-libva@$VERSION.tar.gz"
doas rm -rf $DESTDIR
