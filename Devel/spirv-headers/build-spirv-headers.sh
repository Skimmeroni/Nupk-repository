#!/bin/sh

set -eu

PRETTY_NAME=spirv-headers
MAJOR=1
MINOR=4
PATCH=328
VERSION=1.4.328.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/KhronosGroup/SPIRV-Headers/archive/vulkan-sdk-$VERSION.tar.gz

gzip -cd vulkan-sdk-$VERSION.tar.gz | tar -x
cd SPIRV-Headers-vulkan-sdk-$VERSION

cmake -B build \
	-D CMAKE_BUILD_TYPE=Release \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D SPIRV_HEADERS_ENABLE_TESTS=OFF \
	-D SPIRV_HEADERS_ENABLE_INSTALL=ON \
	-G Ninja

cmake --build build
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-spirv-headers@$VERSION.tar.gz"
doas rm -rf $DESTDIR
