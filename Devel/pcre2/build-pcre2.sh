#!/bin/sh -e

PRETTY_NAME=pcre2
MAJOR=10
MINOR=47
PATCH=
VERSION=10.47

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

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
doas sh -c "tar -zcC $DESTDIR . | gzip > ../pcre2@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
