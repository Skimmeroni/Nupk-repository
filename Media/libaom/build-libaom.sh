#!/bin/sh

set -eu

PRETTY_NAME=libaom
MAJOR=3
MINOR=13
PATCH=1
VERSION=3.13.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://storage.googleapis.com/aom-releases/libaom-$VERSION.tar.gz

gzip -cd libaom-$VERSION.tar.gz | tar -x
cd libaom-$VERSION

cmake -B build \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D ENABLE_DOCS=OFF \
	-D ENABLE_EXAMPLES=OFF \
	-D ENABLE_TESTS=OFF \
	-D ENABLE_TOOLS=OFF \
	-D ENABLE_WERROR=OFF \
	-D CONFIG_TUNE_BUTTERAUGLI=0 \
	-D BUILD_SHARED_LIBS=1 \
	-G Ninja

cmake --build build --verbose
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-libaom@$VERSION.tar.gz"
doas rm -rf $DESTDIR
