#!/bin/sh -e

PRETTY_NAME=binutils
MAJOR=2
MINOR=45
PATCH=1
VERSION=2.45.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/binutils/binutils-$VERSION.tar.xz

tar -xf binutils-$VERSION.tar.xz
cd binutils-$VERSION

./configure \
	--prefix=/usr \
	--with-lib-path=/usr/lib \
	--enable-ld=default \
	--enable-plugins \
	--disable-jansson \
	--disable-gold \
	--disable-lto \
	--disable-multilib \
	--disable-werror \
	--disable-gdb \
	--disable-nls \
	--disable-readline \
	--disable-gprof \
	--disable-gprofng \
	--with-mmap \
	--with-system-zlib \
	--without-zstd

make configure-host
make tooldir=/usr
make tooldir=/usr DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/info"
find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Lang-binutils@$VERSION.tar.gz"
doas rm -rf $DESTDIR
