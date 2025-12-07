#!/bin/sh

set -eu

PRETTY_NAME=spirv-llvm-translator
MAJOR=20
MINOR=1
PATCH=8
VERSION=20.1.8

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/KhronosGroup/SPIRV-LLVM-Translator/archive/v$VERSION/SPIRV-LLVM-Translator-$VERSION.tar.gz

gzip -cd SPIRV-LLVM-Translator-$VERSION.tar.gz | tar -x
cd SPIRV-LLVM-Translator-$VERSION

cmake -B build \
	-D CMAKE_BUILD_TYPE=Release \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D LLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=/usr/include/spirv \
	-D LLVM_SPIRV_INCLUDE_TESTS=OFF \
	-G Ninja

cmake --build build --verbose
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-spirv-llvm-translator@$VERSION.tar.gz"
doas rm -rf $DESTDIR
