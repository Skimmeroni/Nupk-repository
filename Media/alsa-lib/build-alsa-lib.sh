#!/bin/sh

set -eu

PRETTY_NAME=alsa-lib
MAJOR=1
MINOR=2
PATCH=14
VERSION=1.2.14

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://www.alsa-project.org/files/pub/lib/alsa-lib-$VERSION.tar.bz2

bzip2 -cd alsa-lib-$VERSION.tar.bz2 | tar -x
cd alsa-lib-$VERSION

# NOTE: it's not possible to compile both the static and the
# dynamic libraries at the same time. It's one or the other
./configure \
	--prefix=/usr \
	--enable-shared \
	--disable-static \
	--disable-python \
	--without-debug

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-alsa-lib@$VERSION.tar.gz"
doas rm -rf $DESTDIR
