#!/bin/sh -e

PRETTY_NAME=spirv-tools
MAJOR=1
MINOR=4
PATCH=328
VERSION=1.4.328.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/KhronosGroup/SPIRV-Tools/archive/vulkan-sdk-$VERSION.tar.gz

gzip -cd vulkan-sdk-$VERSION.tar.gz | tar -x
cd SPIRV-Tools-vulkan-sdk-$VERSION

# Taken from Gentoo
cmake -B build \
	-D CMAKE_BUILD_TYPE=Release \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_C_FLAGS="$CFLAGS -DNDEBUG" \
	-D CMAKE_CXX_FLAGS="$CXXFLAGS -DNDEBUG" \
	-D SPIRV-Headers_SOURCE_DIR=/usr \
	-D SPIRV_WERROR=OFF \
	-D SPIRV_SKIP_TESTS=ON \
	-D SPIRV_TOOLS_BUILD_STATIC=OFF \
	-G Ninja

cmake --build build
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-spirv-tools@$VERSION.tar.gz"
doas rm -rf $DESTDIR
