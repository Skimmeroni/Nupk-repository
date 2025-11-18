#!/bin/sh -e

PRETTY_NAME=vi
MAJOR=
MINOR=
PATCH=
VERSION=git

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

git clone https://github.com/kyx0r/nextvi.git
cd nextvi.git

export CFLAGS="$CFLAGS -static" 

CC=cc ./cbuild.sh

install -Dm755 vi "$DESTDIR/usr/bin/vi"
strip --strip-unneeded "$DESTDIR/usr/bin/vi"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../nextvi@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
