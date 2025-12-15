#!/bin/sh

set -eu

PRETTY_NAME=swig
MAJOR=4
MINOR=4
PATCH=1
VERSION=4.4.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://downloads.sourceforge.net/swig/swig-$VERSION.tar.gz

gzip -cd swig-$VERSION.tar.gz | tar -x
cd swig-$VERSION

./configure \
	--prefix=/usr \
	--with-pcre \
	--without-ccache

make
make DESTDIR=$DESTDIR install

strip --strip-unneeded "$DESTDIR/usr/bin/swig"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-swig@$VERSION.tar.gz"
doas rm -rf $DESTDIR
