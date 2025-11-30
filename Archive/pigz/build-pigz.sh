#!/bin/sh -e

PRETTY_NAME=pigz
MAJOR=2
MINOR=8
PATCH=
VERSION=2.8

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://zlib.net/pigz/pigz-$VERSION.tar.gz

gzip -cd pigz-$VERSION.tar.gz | tar -x
cd pigz-$VERSION

$CC -c *.c -DNOZOPFLI
$CC -static -o pigz *.o -lz

install -Dm755 pigz "$DESTDIR/usr/bin/pigz"
install -Dm644 pigz.1 "$DESTDIR/usr/share/man/man1/pigz.1"
strip --strip-unneeded "$DESTDIR/usr/bin/pigz"
ln -sf pigz "$DESTDIR/usr/bin/gzip"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Archive-pigz@$VERSION.tar.gz"
doas rm -rf $DESTDIR
