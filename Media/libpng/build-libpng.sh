#!/bin/sh -e

PRETTY_NAME=libpng
MAJOR=1
MINOR=6
PATCH=51
VERSION=1.6.51

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://www.github.com/pnggroup/libpng/archive/refs/tags/v$VERSION.tar.gz
curl --location --remote-name --skip-existing https://downloads.sourceforge.net/sourceforge/libpng-apng/libpng-$VERSION-apng.patch.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd libpng-$VERSION

# LFS suggests adding support for animated PNGs, needed for building firefox
gzip -cd ../libpng-$VERSION-apng.patch.gz | patch -p1

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static \
	--disable-tests \
	--disable-tools

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type fl -name '*.la' -delete

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Media-libpng@$VERSION.tar.gz"
doas rm -rf $DESTDIR
