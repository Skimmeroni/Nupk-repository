#!/bin/sh

set -eu

PRETTY_NAME=tesseract-ocr
MAJOR=5
MINOR=5
PATCH=1
VERSION=5.5.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/tesseract-ocr/tesseract/archive/refs/tags/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd tesseract-$VERSION

# TODO: why aren't static libraries built?
cmake -B build \
	-D CMAKE_BUILD_TYPE=Release \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D BUILD_SHARED_LIBS=ON \
	-D BUILD_TESTS=OFF \
	-D BUILD_TRAINING_TOOLS=OFF \
	-D DISABLED_LEGACY_ENGINE=ON \
	-D DISABLE_ARCHIVE=ON \
	-D DISABLE_CURL=ON \
	-D ENABLE_NATIVE=ON \
	-D GRAPHICS_DISABLED=ON \
	-G Ninja

cmake --build build --verbose
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-tesseract@$VERSION.tar.gz"
doas rm -rf $DESTDIR
