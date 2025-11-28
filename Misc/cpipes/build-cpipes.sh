#!/bin/sh -e

PRETTY_NAME=pipes.c
MAJOR=1
MINOR=2
PATCH=1
VERSION=1.2.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/pipeseroni/pipes.c/releases/download/v$VERSION/pipes-c-$VERSION.tar.gz

gzip -cd pipes-c-$VERSION.tar.gz | tar -x
cd pipes-c-$VERSION

./configure \
	--prefix=/usr \
	--with-ncursesw

make
make DESTDIR=$DESTDIR install-strip

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Misc-cpipes@$VERSION.tar.gz"
doas rm -rf $DESTDIR
