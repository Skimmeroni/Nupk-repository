#!/bin/sh

set -eu

PRETTY_NAME=samurai-build-tool
MAJOR=1
MINOR=2
PATCH=
VERSION=1.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name https://github.com/michaelforney/samurai/releases/download/$VERSION/samurai-$VERSION.tar.gz

gzip -cd samurai-$VERSION.tar.gz | tar -x
cd samurai-$VERSION

make PREFIX=/usr
make PREFIX=/usr DESTDIR=$DESTDIR install

strip --strip-unneeded "$DESTDIR/usr/bin/samu"

ln -sf samu   $DESTDIR/usr/bin/ninja
ln -sf samu.1 $DESTDIR/usr/share/man/man1/ninja.1

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-samurai@$VERSION.tar.gz"
doas rm -rf $DESTDIR
