#!/bin/sh -e

PRETTY_NAME=lcms
MAJOR=2
MINOR=17
PATCH=
VERSION=2.17

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/mm2/Little-CMS/archive/refs/tags/lcms$VERSION.tar.gz

gzip -cd lcms$VERSION.tar.gz | tar -x
cd Little-CMS-lcms$VERSION

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static \
	--with-jpeg \
	--with-tiff \
	--with-zlib

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-lcms@$VERSION.tar.gz"
doas rm -rf $DESTDIR
