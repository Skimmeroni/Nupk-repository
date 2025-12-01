#!/bin/sh

set -eu

PRETTY_NAME=llvm
MAJOR=20
MINOR=1
PATCH=8
VERSION=20.1.8

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/llvm/llvm-project/releases/download/llvmorg-$VERSION/clang-$VERSION.src.tar.xz
curl --location --remote-name --skip-existing https://github.com/llvm/llvm-project/releases/download/llvmorg-$VERSION/cmake-$VERSION.src.tar.xz

xz -cd cmake-$VERSION.src.tar.xz | tar -x
mv cmake-$VERSION.src cmake
xz -cd clang-$VERSION.src.tar.xz | tar -x
cd clang-$VERSION.src

# For convenience, only native target is built.
# May or may not be what you want
# TODO: lto?
cmake -B build \
	-D CMAKE_BUILD_TYPE=Release \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D LLVM_BUILD_LLVM_DYLIB=ON \
	-D LLVM_LINK_LLVM_DYLIB=ON \
	-D LLVM_ENABLE_RTTI=ON \
	-D LLVM_HOST_TRIPLE=$(cc -dumpmachine) \
	-D LLVM_TARGETS_TO_BUILD=host \
	-D LLVM_INCLUDE_DOCS=OFF \
	-D LLVM_INCLUDE_TESTS=OFF \
	-D LLVM_ENABLE_CURL=OFF \
	-D LLVM_ENABLE_LIBEDIT=OFF \
	-D LLVM_ENABLE_LIBXML2=OFF \
	-D LLVM_ENABLE_ZLIB=ON \
	-D LLVM_ENABLE_LTO=OFF \
	-D LLVM_ENABLE_ZSTD=OFF \
	-W no-dev -G Ninja

cmake --build build
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Lang-clang@$VERSION.tar.gz"
doas rm -rf $DESTDIR
