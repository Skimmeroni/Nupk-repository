#!/bin/sh -e

### MARKED FOR REMOVAL ###

PRETTY_NAME=iproute2
MAJOR=6
MINOR=16
PATCH=0
VERSION=6.16.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-$VERSION.tar.xz

xz -cd iproute2-$VERSION.tar.xz | tar -x
cd iproute2-$VERSION

sed 's/CC := gcc/CC ?= gcc/g' Makefile > Makefile.new
mv Makefile.new Makefile

./configure --include_dir /usr/include

make KERNEL_INCLUDE=y

install -Dm755 ip/ip "$DESTDIR/usr/bin/ip"
install -Dm755 tc/tc "$DESTDIR/usr/bin/tc"

install -Dm644 include/libnetlink.h "$DESTDIR/usr/include/libnetlink.h"
install -Dm644 lib/libnetlink.a     "$DESTDIR/usr/lib/libnetlink.a"

mkdir -p "$DESTDIR/usr/share/man/man8"
cp man/man8/ip* "$DESTDIR/usr/share/man/man8"
cp man/man8/tc* "$DESTDIR/usr/share/man/man8"

strip --strip-unneeded "$DESTDIR/usr/bin/ip"
strip --strip-unneeded "$DESTDIR/usr/bin/tc"
strip --strip-unneeded "$DESTDIR/usr/lib/libnetlink.a"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Net-iproute2@$VERSION.tar.gz"
doas rm -rf $DESTDIR
