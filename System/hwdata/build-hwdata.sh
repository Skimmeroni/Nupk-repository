#!/bin/sh -e

PRETTY_NAME=hwdata
MAJOR=0
MINOR=401
PATCH=
VERSION=0.401

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/vcrhonek/hwdata/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd hwdata-$VERSION

./configure \
	--prefix=/usr \
	--disable-blacklist

make DESTDIR=$DESTDIR install

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../System-hwdata@$VERSION.tar.gz"
doas rm -rf $DESTDIR
