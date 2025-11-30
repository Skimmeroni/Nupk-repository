#!/bin/sh -e

PRETTY_NAME=llvm
MAJOR=20
MINOR=1
PATCH=8
VERSION=20.1.8

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/llvm/llvm-project/releases/download/llvmorg-$VERSION/llvm-$VERSION.src.tar.xz
curl --location --remote-name --skip-existing https://github.com/llvm/llvm-project/releases/download/llvmorg-$VERSION/cmake-$VERSION.src.tar.xz

xz -cd cmake-$VERSION.src.tar.xz | tar -x
mv cmake-$VERSION.src cmake
xz -cd llvm-$VERSION.src.tar.xz | tar -x
cd llvm-$VERSION.src

# For convenience, only native target is built.
# May or may not be what you want
# TODO: lto?
cmake -B build \
	-D CMAKE_BUILD_TYPE=Release \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D LLVM_BUILD_LLVM_DYLIB=ON \
	-D LLVM_LINK_LLVM_DYLIB=ON \
	-D LLVM_ENABLE_RTTI=ON \
	-D LLVM_DEFAULT_TARGET_TRIPLE=$(cc -dumpmachine) \
	-D LLVM_HOST_TRIPLE=$(cc -dumpmachine) \
	-D LLVM_TARGETS_TO_BUILD=host \
	-D LLVM_INCLUDE_BENCHMARKS=OFF \
	-D LLVM_INCLUDE_EXAMPLES=OFF \
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

# Sligthly edited from KISS to clean up messy paths, not exactly reliable
# Useful to build mesa, for example
# TODO: grep -o is a GNU thing and should be avoided
sed -e "s#@LLVM_HAS_RTTI@#$(build/bin/llvm-config --has-rtti)#g" \
    -e "s#@LLVM_VERSION@#$(build/bin/llvm-config --version)#g" \
    -e "s#@LLVM_LIBS@#$(build/bin/llvm-config --libs | grep -o '\-l.*')#g" \
    -e "s#@LLVM_LIBS_LINK_STATIC@#$(build/bin/llvm-config --libs --link-static | grep -o '\-l.*')#g" \
    -e "s#@LLVM_CFLAGS@#$(build/bin/llvm-config --cflags | grep -o '\-D.*')#g" ../llvm.pc.stub > ../llvm.pc
install -Dm644 ../llvm.pc $DESTDIR/usr/lib/pkgconfig/llvm.pc

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-llvm@$VERSION.tar.gz"
doas rm -rf $DESTDIR
