#!/bin/sh -e

PRETTY_NAME=expat
MAJOR=2
MINOR=7
PATCH=3
VERSION=2.7.3

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/libexpat/libexpat/releases/download/R\_$MAJOR\_$MINOR\_$PATCH/expat-$VERSION.tar.xz

xz -cd expat-$VERSION.tar.xz | tar -x
cd expat-$VERSION

./configure \
	--prefix=/usr \
	--without-xmlwf \
	--without-examples \
	--without-tests \
	--without-docbook

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share"
find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../System-expat@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
