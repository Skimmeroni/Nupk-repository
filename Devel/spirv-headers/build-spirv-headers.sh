#!/bin/sh -e

PRETTY_NAME=spirv-headers
MAJOR=1
MINOR=4
PATCH=328
VERSION=1.4.328.0

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

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
doas sh -c "tar -zcC $DESTDIR . | gzip > ../spirv-headers@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
