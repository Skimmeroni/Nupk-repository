#!/bin/sh -e

PRETTY_NAME=xz
MAJOR=5
MINOR=8
PATCH=1
VERSION=5.8.1

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://tukaani.org/xz/xz-$VERSION.tar.gz

gzip -cd xz-$VERSION.tar.gz | tar -x
cd xz-$VERSION

./configure \
    --prefix=/usr \
    --disable-doc \
    --disable-nls

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Archive-xz@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
