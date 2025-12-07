#!/bin/sh

set -eu

PRETTY_NAME=x264
MAJOR=
MINOR=
PATCH=
VERSION=4613ac3c15fd75cebc4b9f65b7fb95e70a3acce1

# The naming scheme of x264 is confusing

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://code.videolan.org/videolan/x264/-/archive/$VERSION/x264-$VERSION.tar.gz

gzip -cd x264-$VERSION.tar.gz | tar -x
cd x264-$VERSION

./configure \
	--prefix=/usr \
	--libdir=/usr/lib \
	--enable-shared \
	--enable-static \
	--disable-opencl \
	--disable-cli

make
make DESTDIR=$DESTDIR install

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-x264@$VERSION.tar.gz"
doas rm -rf $DESTDIR
