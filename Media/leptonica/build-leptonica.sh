#!/bin/sh -e

PRETTY_NAME=leptonica
MAJOR=1
MINOR=86
PATCH=0
VERSION=1.86.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/DanBloomberg/leptonica/releases/download/$VERSION/leptonica-$VERSION.tar.gz

gzip -cd leptonica-$VERSION.tar.gz | tar -x
cd leptonica-$VERSION

./configure \
	--prefix=/usr \
	--disable-programs \
	--enable-shared \
	--enable-static \
	--with-giflib \
	--with-jpeg \
	--with-libpng \
	--with-libwebp \
	--with-libwebpmux \
	--with-zlib \
	--with-libtiff \
	--with-libopenjpeg

make
make DESTDIR=$DESTDIR install-strip

install -Dm644 leptonica-license.txt "$DESTDIR/usr/share/LICENSES/leptonica.license"

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-leptonica@$VERSION.tar.gz"
doas rm -rf $DESTDIR
