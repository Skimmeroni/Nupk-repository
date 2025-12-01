#!/bin/sh

set -eu

PRETTY_NAME=fontconfig
MAJOR=2
MINOR=17
PATCH=1
VERSION=2.17.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://gitlab.freedesktop.org/api/v4/projects/890/packages/generic/fontconfig/$VERSION/fontconfig-$VERSION.tar.xz

xz -cd fontconfig-$VERSION.tar.xz | tar -x
cd fontconfig-$VERSION

./configure \
	--prefix=/usr \
	--localstatedir=/var \
	--sysconfdir=/etc \
	--enable-static \
	--enable-shared \
	--disable-docs \
	--disable-nls

make
make DESTDIR=$DESTDIR install-strip

mkdir -p $DESTDIR/usr/share/man/man1
install -m644 fc-*/*.1 $DESTDIR/usr/share/man/man1

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-fontconfig@$VERSION.tar.gz"
doas rm -rf $DESTDIR
