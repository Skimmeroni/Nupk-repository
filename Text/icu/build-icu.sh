#!/bin/sh

set -eu

PRETTY_NAME=icu
MAJOR=
MINOR=
PATCH=
VERSION=78.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/unicode-org/icu/releases/download/release-$VERSION/icu4c-$VERSION-sources.tgz

gzip -cd icu4c-$VERSION-sources.tgz | tar -x
cd icu/source

# ACTUALLY disable the versioning macro
sed 's|#define U_DISABLE_RENAMING 0|#define U_DISABLE_RENAMING 1|g' common/unicode/uconfig.h > common/unicode/uconfig.h.new
mv common/unicode/uconfig.h.new common/unicode/uconfig.h

./configure \
	CC=gcc \
	CXX=g++ \
	--prefix=/usr \
	--sbindir=/usr/bin \
	--enable-shared \
	--enable-static \
	--disable-renaming \
	--disable-samples \
	--disable-debug \
	--disable-tests \
	--disable-tools \
	--disable-extras \
	--disable-layoutex

make
make DESTDIR=$DESTDIR install

find "$DESTDIR/usr/lib" -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-icu@$VERSION.tar.gz"
doas rm -rf $DESTDIR
