#!/bin/sh -e

PRETTY_NAME=giflib
MAJOR=5
MINOR=2
PATCH=2
VERSION=5.2.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://downloads.sourceforge.net/project/giflib/giflib-$VERSION.tar.gz

gzip -cd giflib-$VERSION.tar.gz | tar -x
cd giflib-$VERSION

# From Gentoo: prevent a dependency on ImageMagick
sed '/$(MAKE) -C doc/d' Makefile > Makefile.new
mv Makefile.new Makefile

make PREFIX=/usr CFLAGS="$CFLAGS -std=gnu99 -fPIC"
make PREFIX=/usr CFLAGS="$CFLAGS -std=gnu99 -fPIC" DESTDIR=$DESTDIR install

find $DESTDIR/usr/bin       -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so'  -type f -exec strip --strip-unneeded {} \;

# Manuals are in XML format (eww)
rm -rf $DESTDIR/usr/share

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-giflib@$VERSION.tar.gz"
doas rm -rf $DESTDIR
