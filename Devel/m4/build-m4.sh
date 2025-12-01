#!/bin/sh

set -eu

PRETTY_NAME=m4
MAJOR=1
MINOR=4
PATCH=20
VERSION=1.4.20

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/m4/m4-$VERSION.tar.xz

xz -cd m4-$VERSION.tar.xz | tar -x
cd m4-$VERSION

./configure --prefix=/usr --disable-nls

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/info"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-m4@$VERSION.tar.gz"
doas rm -rf $DESTDIR
