#!/bin/sh

set -eu

PRETTY_NAME=libplacebo
MAJOR=7
MINOR=351
PATCH=0
VERSION=7.351.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://code.videolan.org/videolan/libplacebo/-/archive/v$VERSION/libplacebo-v$VERSION.tar.bz2

bzip2 -cd libplacebo-v$VERSION.tar.bz2 | tar -x
cd libplacebo-v$VERSION

# Vulkan is erroneously included even if absent
if [ ! $(pkg-config --exists vulkan) ]
then
	sed "s|sources += 'vulkan/stubs.c'|sources += []|" src/vulkan/meson.build > src/vulkan/meson.build.new
	mv src/vulkan/meson.build.new src/vulkan/meson.build
fi

meson setup \
	-D prefix=/usr \
	-D default_library=both \
	-D buildtype=release \
	-D strip=true \
	-D opengl=enabled \
	-D lcms=enabled \
	-D glslang=disabled \
	-D xxhash=disabled \
	-D demos=false \
	-D tests=false \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-libplacebo@$VERSION.tar.gz"
doas rm -rf $DESTDIR
