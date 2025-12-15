#!/bin/sh

set -eu

PRETTY_NAME=automake
MAJOR=1
MINOR=18
PATCH=1
VERSION=1.18.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/automake/automake-$VERSION.tar.xz

xz -cd automake-$VERSION.tar.xz | tar -x
cd automake-$VERSION

./configure --prefix=/usr

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/info"
rm -rf "$DESTDIR/usr/share/doc"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Build-automake@$VERSION.tar.gz"
doas rm -rf $DESTDIR
