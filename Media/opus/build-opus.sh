#!/bin/sh -e

PRETTY_NAME=opus
MAJOR=1
MINOR=5
PATCH=2
VERSION=1.5.2

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://downloads.xiph.org/releases/opus/opus-$VERSION.tar.gz

gzip -cd opus-$VERSION.tar.gz | tar -x
cd opus-$VERSION

./configure \
	--prefix=/usr \
	--enable-custom-modes \
	--disable-doc \
	--disable-extra-programs

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Media-opus@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
