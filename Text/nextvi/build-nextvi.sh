#!/bin/sh

set -eu

PRETTY_NAME=vi
MAJOR=
MINOR=
PATCH=
VERSION=git

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

git clone https://github.com/kyx0r/nextvi.git
cd nextvi.git

export CFLAGS="$CFLAGS -static" 

CC=cc ./cbuild.sh

install -Dm755 vi "$DESTDIR/usr/bin/vi"
strip --strip-unneeded "$DESTDIR/usr/bin/vi"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-nextvi@$VERSION.tar.gz"
doas rm -rf $DESTDIR
