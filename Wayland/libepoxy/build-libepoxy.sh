#!/bin/sh -e

PRETTY_NAME=libepoxy
MAJOR=1
MINOR=5
PATCH=10
VERSION=1.5.10

mkdir temporary-builddir
DESTDIR="$PWD/temporary-builddir"

curl --location --remote-name --skip-existing https://github.com/anholt/libepoxy/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd libepoxy-$VERSION

muon setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D egl=yes \
	-D glx=no \
	-D docs=false \
	-D x11=false \
	-D tests=false \
	build

ninja -C build
muon -C build install -d $DESTDIR

find "$DESTDIR/usr/lib" -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.so*' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Wayland-libepoxy@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
