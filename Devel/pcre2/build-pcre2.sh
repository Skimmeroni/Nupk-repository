#!/bin/sh

set -eu

PRETTY_NAME=pcre2
MAJOR=10
MINOR=47
PATCH=
VERSION=10.47

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/PCRE2Project/pcre2/releases/download/pcre2-$VERSION/pcre2-$VERSION.tar.bz2

bzip2 -cd pcre2-$VERSION.tar.bz2 | tar -x
cd pcre2-$VERSION

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static \
	--enable-pcre2-8 \
	--enable-pcre2-16 \
	--enable-pcre2-32 \
	--enable-unicode \
	--disable-pcre2grep-libz \
	--disable-pcre2grep-libbz2 \
	--disable-pcre2test-libedit \
	--disable-jit \
	--disable-debug

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/man/man3"
rm -rf "$DESTDIR/usr/share/doc"

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-pcre2@$VERSION.tar.gz"
doas rm -rf $DESTDIR
