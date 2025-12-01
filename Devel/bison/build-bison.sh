#!/bin/sh

set -eu

PRETTY_NAME=bison
MAJOR=3
MINOR=8
PATCH=2
VERSION=3.8.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/bison/bison-$VERSION.tar.xz

xz -cd bison-$VERSION.tar.xz | tar -x
cd bison-$VERSION

./configure \
	--prefix=/usr \
	--disable-nls \
	--without-libtextstyle-prefix

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/info"
rm -rf "$DESTDIR/usr/share/doc"
rm -rf "$DESTDIR/usr/share/aclocal"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-bison@$VERSION.tar.gz"
doas rm -rf $DESTDIR
