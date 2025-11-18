#!/bin/sh -e

PRETTY_NAME=libxkbcommon
MAJOR=1
MINOR=13
PATCH=0
VERSION=1.13.0

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://github.com/xkbcommon/libxkbcommon/archive/refs/tags/xkbcommon-$VERSION.tar.gz

gzip -cd xkbcommon-$VERSION.tar.gz | tar -x
cd libxkbcommon-xkbcommon-$VERSION

muon setup \
	-D prefix=/usr \
	-D libdir=/usr/lib \
	-D libexecdir=/usr/lib \
	-D buildtype=release \
	-D default_library=both \
	-D enable-docs=false \
	-D enable-tools=false \
	-D enable-wayland=true \
	-D enable-x11=false \
	-D enable-bash-completion=false \
	-D enable-xkbregistry=false \
	build

ninja -C build
muon -C build install -d "$DESTDIR"

find $DESTDIR -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find $DESTDIR -type f -name '*.so*' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../libxkbcommon@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
