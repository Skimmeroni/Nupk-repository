#!/bin/sh -e

PRETTY_NAME=tiff
MAJOR=4
MINOR=7
PATCH=1
VERSION=4.7.1

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://download.osgeo.org/libtiff/tiff-$VERSION.tar.gz

gzip -cd tiff-$VERSION.tar.gz | tar -x
cd tiff-$VERSION

./configure \
	--prefix=/usr \
	--enable-cxx \
	--enable-jpeg \
	--enable-shared \
	--enable-static \
	--enable-lzma \
	--enable-zlib \
	--enable-webp \
	--disable-docs \
	--disable-jpeg12 \
	--disable-jbig \
	--disable-lerc \
	--disable-opengl \
	--disable-sphinx \
	--disable-tools \
	--disable-tests \
	--disable-zstd \
	--without-x

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Media-libtiff@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
