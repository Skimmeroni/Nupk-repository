#!/bin/sh

set -eu

PRETTY_NAME=poppler
MAJOR=25
MINOR=12
PATCH=0
VERSION=25.12.0

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://poppler.freedesktop.org/poppler-$VERSION.tar.xz

xz -cd poppler-$VERSION.tar.xz | tar -x
cd poppler-$VERSION

cmake -B build \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D ENABLE_UNSTABLE_API_ABI_HEADERS=ON \
	-D ENABLE_UTILS=ON \
	-D WITH_Cairo=ON \
	-D ENABLE_CPP=ON \
	-D WITH_JPEG=ON \
	-D ENABLE_DCTDECODER=libjpeg \
	-D ENABLE_LIBOPENJPEG=openjpeg2 \
	-D WITH_PNG=ON \
	-D ENABLE_LIBTIFF=ON \
	-D ENABLE_LCMS=ON \
	-D BUILD_GTK_TESTS=OFF \
	-D BUILD_CPP_TESTS=OFF \
	-D BUILD_MANUAL_TESTS=OFF \
	-D RUN_GPERF_IF_PRESENT=OFF \
	-D ENABLE_BOOST=OFF \
	-D ENABLE_LIBCURL=OFF \
	-D ENABLE_GPGME=OFF \
	-D ENABLE_NSS3=OFF \
	-D ENABLE_QT5=OFF \
	-D ENABLE_QT6=OFF \
	-D WITH_GObjectIntrospection=OFF \
	-G Ninja

cmake --build build --verbose
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-poppler@$VERSION.tar.gz"
doas rm -rf $DESTDIR
