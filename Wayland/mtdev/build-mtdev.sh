#!/bin/sh -e

PRETTY_NAME=mtdev
MAJOR=1
MINOR=1
PATCH=7
VERSION=1.1.7

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://bitmath.org/code/mtdev/mtdev-$VERSION.tar.bz2

bzip2 -cd mtdev-$VERSION.tar.bz2 | tar -x
cd mtdev-$VERSION

./configure --prefix=/usr

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Wayland-mtdev@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
