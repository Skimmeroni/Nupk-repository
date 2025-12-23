#!/bin/sh

set -eu

PRETTY_NAME=nspr
MAJOR=4
MINOR=38
PATCH=
VERSION=4.38

# Taken pretty much word-for-word from https://packages.gentoo.org/packages/dev-libs/nspr

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://archive.mozilla.org/pub/nspr/releases/v$VERSION/src/nspr-$VERSION.tar.gz
curl --location --remote-name --skip-existing https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-libs/nspr/files/nspr-4.35-bgo-905998-lfs64-musl.patch
curl --location --remote-name --skip-existing https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-libs/nspr/files/nspr-4.21-ipv6-musl-support.patch

gzip -cd nspr-$VERSION.tar.gz | tar -x
cd nspr-$VERSION/nspr

# Borrow Gentoo patches to support musl
patch -p1 < ../../nspr-4.35-bgo-905998-lfs64-musl.patch
patch -p1 < ../../nspr-4.21-ipv6-musl-support.patch

mkdir build-directory
cd build-directory

# It could be argued that not all machines are 64bit...
../configure \
	--prefix=/usr \
	--disable-debug \
	--enable-optimize \
	--enable-64bit

make
make DESTDIR=$DESTDIR install

rm -rf "$DESTDIR/usr/share"
rm "$DESTDIR/usr/bin/prerr.properties"
rm "$DESTDIR/usr/bin/compile-et.pl"

find $DESTDIR -name '*.a' -delete
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-nspr@$VERSION.tar.gz"
doas rm -rf $DESTDIR
