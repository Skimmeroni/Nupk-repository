#!/bin/sh -e

### MARKED FOR REMOVAL ###

PRETTY_NAME=brotli
MAJOR=1
MINOR=1
PATCH=0
VERSION=1.1.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/google/brotli/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd brotli-$VERSION

cmake -B build \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D BUILD_SHARED_LIBS=True \
	-G Ninja

cmake --build build
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Archive-brotli@$VERSION.tar.gz"
doas rm -rf $DESTDIR
