#!/bin/sh -e

PRETTY_NAME=pipes.c
MAJOR=1
MINOR=2
PATCH=1
VERSION=1.2.1

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://github.com/pipeseroni/pipes.c/releases/download/v$VERSION/pipes-c-$VERSION.tar.gz

gzip -cd pipes-c-$VERSION.tar.gz | tar -x
cd pipes-c-$VERSION

./configure \
	--prefix=/usr \
	--with-ncursesw

make
make DESTDIR=$DESTDIR install-strip

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../cpipes@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
