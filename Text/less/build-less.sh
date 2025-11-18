#!/bin/sh -e

PRETTY_NAME=less
MAJOR=6
MINOR=6
PATCH=8
VERSION=668

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing http://www.greenwoodsoftware.com/less/less-$VERSION.tar.gz

gzip -cd less-$VERSION.tar.gz | tar -x
cd less-$VERSION

./configure --prefix=/usr

make
make DESTDIR=$DESTDIR install-strip

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../less@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
