#!/bin/sh -e

PRETTY_NAME=lame
MAJOR=3
MINOR=100
PATCH=
VERSION=3.100

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://fossies.org/linux/misc/lame-$VERSION.tar.gz

gzip -cd lame-$VERSION.tar.gz | tar -x
cd lame-$VERSION

./configure \
	--prefix=/usr \
	--disable-debug \
	--disable-frontend \
	--disable-gtktest \
	--enable-shared \
	--enable-static

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share"
find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Media-lame@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
