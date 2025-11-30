#!/bin/sh -e

PRETTY_NAME=libuv
MAJOR=1
MINOR=51
PATCH=0
VERSION=1.51.0

# NOTE: this is the only (sort of) mandatory package that requires
# autotools. It can also be built using cmake, but cmake itself
# requires libuv to be built. How ironic

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://www.github.com/libuv/libuv/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd libuv-$VERSION

sh autogen.sh
./configure --prefix=/usr
make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-libuv@$VERSION.tar.gz"
doas rm -rf $DESTDIR
