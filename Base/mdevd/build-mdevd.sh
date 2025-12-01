#!/bin/sh

set -eu

PRETTY_NAME=mdevd
MAJOR=0
MINOR=1
PATCH=7
VERSION=0.1.7.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/skarnet/mdevd/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd mdevd-$VERSION

./configure \
	--prefix=/usr \
	--enable-static-libc

make
make DESTDIR=$DESTDIR install

install -Dm644 ../mdev.conf "$DESTDIR/etc/mdev.conf"
install -Dm755 ../mdevd.run  "$DESTDIR/etc/sv/mdevd/run"
ln -sf /run/runit/supervise.mdevd "$DESTDIR/etc/sv/mdevd/supervise"

strip --strip-unneeded "$DESTDIR/usr/bin/mdevd"
strip --strip-unneeded "$DESTDIR/usr/bin/mdevd-coldplug"

rm -rf "$DESTDIR/usr/include"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Base-mdevd@$VERSION.tar.gz"
doas rm -rf $DESTDIR
