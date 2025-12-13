#!/bin/sh

set -eu

PRETTY_NAME=alsa-utils
MAJOR=1
MINOR=2
PATCH=14
VERSION=1.2.14

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://www.alsa-project.org/files/pub/utils/alsa-utils-$VERSION.tar.bz2

bzip2 -cd alsa-utils-$VERSION.tar.bz2 | tar -x
cd alsa-utils-$VERSION

./configure \
	--prefix=/usr \
	--disable-alsaconf \
	--disable-nls \
	--disable-xmlto \
	--with-curses=ncursesw \
	--with-udev-rules-dir=/usr/lib/udev/rules.d

make
make DESTDIR=$DESTDIR install-strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-alsa-utils@$VERSION.tar.gz"
doas rm -rf $DESTDIR
