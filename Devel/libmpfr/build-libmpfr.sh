#!/bin/sh -e

PRETTY_NAME=mpfr
MAJOR=4
MINOR=2
PATCH=2
VERSION=4.2.2

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://www.mpfr.org/mpfr-current/mpfr-$VERSION.tar.xz

xz -cd mpfr-$VERSION.tar.xz | tar -x
cd mpfr-$VERSION

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-thread-safe

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share"
find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Devel-libmpfr@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
