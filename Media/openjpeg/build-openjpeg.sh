#!/bin/sh -e

PRETTY_NAME=openjpeg
MAJOR=2
MINOR=5
PATCH=4
VERSION=2.5.4

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/uclouvain/openjpeg/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd openjpeg-$VERSION

cmake -B build \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_INSTALL_LIBDIR=/usr/lib \
	-D CMAKE_BUILD_TYPE=Release \
	-D BUILD_STATIC_LIBS=ON \
	-D BUILD_SHARED_LIBS=ON \
	-D BUILD_DOC=OFF \
	-G Ninja

cmake --build build
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-openjpeg@$VERSION.tar.gz"
doas rm -rf $DESTDIR
