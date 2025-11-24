#!/bin/sh -e

PRETTY_NAME=openjpeg
MAJOR=2
MINOR=5
PATCH=4
VERSION=2.5.4

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

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
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Media-openjpeg@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
