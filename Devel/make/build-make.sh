#!/bin/sh -e

PRETTY_NAME=make
MAJOR=4
MINOR=4
PATCH=1
VERSION=4.4.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/make/make-$VERSION.tar.gz

gzip -cd make-$VERSION.tar.gz | tar -x
cd make-$VERSION

export LDFLAGS="$LDFLAGS -static"

./configure \
	--prefix=/usr \
	--disable-nls \
	--without-guile

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/info"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Devel-make@$VERSION.tar.gz"
doas rm -rf $DESTDIR
