#!/bin/sh -e

PRETTY_NAME=harfbuzz
MAJOR=12
MINOR=2
PATCH=0
VERSION=12.2.0

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://github.com/harfbuzz/harfbuzz/releases/download/$VERSION/harfbuzz-$VERSION.tar.xz

xz -cd harfbuzz-$VERSION.tar.xz | tar -x
cd harfbuzz-$VERSION

muon setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D libdir=/usr/lib \
	-D cairo=enabled \
	-D freetype=enabled \
	-D glib=enabled \
	-D icu=disabled \
	-D benchmark=disabled \
	-D chafa=disabled \
	-D coretext=disabled \
	-D gobject=disabled \
	-D introspection=disabled \
	-D tests=disabled \
	-D wasm=disabled \
	-D fontations=disabled \
	-D docs=disabled \
	-D utilities=disabled \
	build

ninja -C build
muon -C build install -d $DESTDIR

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../harfbuzz@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
