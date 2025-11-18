#!/bin/sh -e

PRETTY_NAME=libva
MAJOR=2
MINOR=22
PATCH=0
VERSION=2.22.0

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

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
doas sh -c "tar -zcC $DESTDIR . | gzip > ../libva@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
