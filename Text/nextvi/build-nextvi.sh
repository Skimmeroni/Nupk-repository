#!/bin/sh -e

PRETTY_NAME=vi
MAJOR=
MINOR=
PATCH=
VERSION=git

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

git clone https://github.com/kyx0r/nextvi.git
cd nextvi.git

export CFLAGS="$CFLAGS -static" 

CC=cc ./cbuild.sh

install -Dm755 vi "$DESTDIR/usr/bin/vi"
strip --strip-unneeded "$DESTDIR/usr/bin/vi"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Text-nextvi@$VERSION.tar.gz"
doas rm -rf $DESTDIR
