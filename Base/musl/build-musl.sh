#!/bin/sh

set -eu

PRETTY_NAME=musl
MAJOR=1
MINOR=2
PATCH=5
VERSION=1.2.5

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

# TODO: KISS includes these compatibility headers for those packages
# that need them. It would be interesting to know which and how many
# packages actually rely on those
# It would also make sense to fetch them from a more reliable location
curl --location --remote-name --skip-existing https://codeberg.org/kiss-community/repo/raw/branch/master/core/musl/files/tree.h
curl --location --remote-name --skip-existing https://codeberg.org/kiss-community/repo/raw/branch/master/core/musl/files/queue.h
curl --location --remote-name --skip-existing https://codeberg.org/kiss-community/repo/raw/branch/master/core/musl/files/cdefs.h
curl --location --remote-name --skip-existing https://codeberg.org/kiss-community/repo/raw/branch/master/core/musl/files/getent.c
curl --location --remote-name --skip-existing https://www.musl-libc.org/releases/musl-$VERSION.tar.gz

mkdir -p "$DESTDIR/usr/bin"
$CC $CFLAGS -static getent.c -o "$DESTDIR/usr/bin/getent"
strip --strip-unneeded "$DESTDIR/usr/bin/getent"

install -Dm644 cdefs.h "$DESTDIR/usr/include/sys/cdefs.h"
install -Dm644 queue.h "$DESTDIR/usr/include/sys/queue.h"
install -Dm644 tree.h  "$DESTDIR/usr/include/sys/tree.h"

gzip -cd musl-$VERSION.tar.gz | tar -x
cd musl-$VERSION

./configure \
	--prefix=/usr \
	--syslibdir=/usr/lib

make
make DESTDIR=$DESTDIR install

sed "s|@ARCHITECTURE@|$(uname -m)|g" ../ldd.stub > ../ldd
install -Dm755 ../ldd "$DESTDIR/usr/bin/ldd"
ln -sf libc.so "$DESTDIR/usr/lib/ld-musl-$(uname -m).so.1"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Base-musl@$VERSION.tar.gz"
doas rm -rf $DESTDIR
