#!/bin/sh

set -eu

PRETTY_NAME=htop
MAJOR=3
MINOR=4
PATCH=1
VERSION=3.4.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/htop-dev/htop/releases/download/$VERSION/htop-$VERSION.tar.xz

xz -cd htop-$VERSION.tar.xz | tar -x
cd htop-$VERSION

./configure \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-unicode

make
make DESTDIR=$DESTDIR install-strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-htop@$VERSION.tar.gz"
doas rm -rf $DESTDIR
