#!/bin/sh

set -eu

PRETTY_NAME=xvidcore
MAJOR=
MINOR=
PATCH=
VERSION=1.3.7

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://downloads.xvid.com/downloads/xvidcore-$VERSION.tar.bz2

bzip2 -cd xvidcore-$VERSION.tar.bz2 | tar -x
cd xvidcore/build/generic

export CFLAGS="$CFLAGS -std=gnu17"
./configure --prefix=/usr --enable-pthread

make
make DESTDIR=$DESTDIR install

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-xvid@$VERSION.tar.gz"
doas rm -rf $DESTDIR
