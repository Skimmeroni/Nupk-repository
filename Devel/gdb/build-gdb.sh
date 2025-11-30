#!/bin/sh -e

PRETTY_NAME=gdb
MAJOR=16
MINOR=3
PATCH=
VERSION=16.3

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/gdb/gdb-$VERSION.tar.xz

xz -cd gdb-$VERSION.tar.xz | tar -x
cd gdb-$VERSION

./configure \
	--prefix=/usr \
	--without-installed-readline \
	--disable-nls \
	--with-system-zlib

make
make -C gdb DESTDIR=$DESTDIR install-strip
make -C gdbserver DESTDIR=$DESTDIR install-strip

find $DESTDIR -name '*.la' -type f -delete
rm -rf $DESTDIR/usr/share/info

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-gdb@$VERSION.tar.gz"
doas rm -rf $DESTDIR
