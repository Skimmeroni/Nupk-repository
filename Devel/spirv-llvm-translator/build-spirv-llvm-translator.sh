#!/bin/sh -e

PRETTY_NAME=spirv-llvm-translator
MAJOR=20
MINOR=1
PATCH=8
VERSION=20.1.8

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/KhronosGroup/SPIRV-LLVM-Translator/archive/v$VERSION/SPIRV-LLVM-Translator-$VERSION.tar.gz

gzip -cd SPIRV-LLVM-Translator-$VERSION.tar.gz | tar -x
cd SPIRV-LLVM-Translator-$VERSION

cmake -B build \
	-D CMAKE_BUILD_TYPE=Release \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D LLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=/usr/include/spirv \
	-D LLVM_SPIRV_INCLUDE_TESTS=OFF \
	-G Ninja

cmake --build build
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Devel-spirv-llvm-translator@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
