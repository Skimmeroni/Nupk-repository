#!/bin/sh -e

PRETTY_NAME=gperf
MAJOR=3
MINOR=3
PATCH=
VERSION=3.3

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/gperf/gperf-$VERSION.tar.gz

gzip -cd gperf-$VERSION.tar.gz | tar -x
cd gperf-$VERSION

./configure --prefix=/usr

make
make DESTDIR=$DESTDIR install

strip --strip-unneeded $DESTDIR/usr/bin/gperf
rm -rf "$DESTDIR/usr/share/doc"
rm -rf "$DESTDIR/usr/share/info"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-gperf@$VERSION.tar.gz"
doas rm -rf $DESTDIR
