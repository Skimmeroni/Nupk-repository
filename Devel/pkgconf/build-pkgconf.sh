#!/bin/sh -e

PRETTY_NAME=pkgconf
MAJOR=2
MINOR=5
PATCH=0
VERSION=2.5.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://distfiles.ariadne.space/pkgconf/pkgconf-$VERSION.tar.xz

xz -cd pkgconf-$VERSION.tar.xz | tar -x
cd pkgconf-$VERSION

./configure \
	--prefix=/usr \
	--sysconfdir=/etc
	
make
make DESTDIR=$DESTDIR install-strip

ln -s pkgconf "$DESTDIR/usr/bin/pkg-config"

rm -rf "$DESTDIR/usr/share/doc"
find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-pkgconf@$VERSION.tar.gz"
doas rm -rf $DESTDIR
