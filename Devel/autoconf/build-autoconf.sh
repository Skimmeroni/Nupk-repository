#!/bin/sh

set -eu

PRETTY_NAME=autoconf
MAJOR=2
MINOR=72
PATCH=
VERSION=2.72

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/autoconf/autoconf-$VERSION.tar.xz

xz -cd autoconf-$VERSION.tar.xz | tar -x
cd autoconf-$VERSION

./configure --prefix=/usr

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/info"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-autoconf@$VERSION.tar.gz"
doas rm -rf $DESTDIR
