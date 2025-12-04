#!/bin/sh

set -eu

PRETTY_NAME=libssh2
MAJOR=1
MINOR=11
PATCH=1
VERSION=1.11.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://libssh2.org/download/libssh2-$VERSION.tar.xz

xz -cd libssh2-$VERSION.tar.xz | tar -x
cd libssh2-$VERSION

cmake -B build \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D BUILD_SHARED_LIBS=ON \
	-D BUILD_STATIC_LIBS=ON \
	-D BUILD_TESTING=OFF \
	-D CRYPTO_BACKEND=OpenSSL \
	-D ENABLE_ZLIB_COMPRESSION=ON \
	-G Ninja

cmake --build build
DESTDIR=$DESTDIR cmake --install build --strip

mkdir -p "$DESTDIR/usr/share/LICENSES"
mv "$DESTDIR/usr/share/doc/libssh2/COPYING" "$DESTDIR/usr/share/LICENSES/libssh2.license"
rm -rf "$DESTDIR/usr/share/doc"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Net-libssh2@$VERSION.tar.gz"
doas rm -rf $DESTDIR
