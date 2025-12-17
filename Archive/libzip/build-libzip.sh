#!/bin/sh

set -eu

PRETTY_NAME=libzip
MAJOR=1
MINOR=11
PATCH=4
VERSION=1.11.4

# Note: as of now, only used by Xournalpp

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://www.nih.at/libzip/libzip-$VERSION.tar.xz

xz -cd libzip-$VERSION.tar.xz | tar -x
cd libzip-$VERSION

cmake -B build \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D ENABLE_BZIP2=ON \
	-D ENABLE_LZMA=ON \
	-D ENABLE_ZSTD=OFF \
	-D ENABLE_COMMONCRYPTO=OFF \
	-D ENABLE_MBEDTLS=OFF \
	-D ENABLE_GNUTLS=OFF \
	-D ENABLE_OPENSSL=OFF \
	-D BUILD_DOC=OFF \
	-D BUILD_OSSFUZZ=OFF \
	-D BUILD_EXAMPLES=OFF \
	-D BUILD_REGRESS=OFF \
	-D BUILD_TOOLS=OFF \
	-G Ninja

cmake --build build --verbose
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Archive-libzip@$VERSION.tar.gz"
doas rm -rf $DESTDIR
