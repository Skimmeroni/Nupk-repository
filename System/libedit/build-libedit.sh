#!/bin/sh -e

PRETTY_NAME=libedit
MAJOR=20251016-3
MINOR=1
PATCH=
VERSION=20251016-3.1

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://www.thrysoee.dk/editline/libedit-$VERSION.tar.gz

gzip -cd libedit-$VERSION.tar.gz | tar -x
cd libedit-$VERSION

./configure \
	--prefix=/usr \
	--enable-static \
	--enable-fast-install

make
make DESTDIR=$DESTDIR install

find $DESTDIR -type f -name '*.la' -delete
rm -rf "$DESTDIR/usr/share/man/man3"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../System-libedit@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
