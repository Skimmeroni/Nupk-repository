#!/bin/sh

set -eu

PRETTY_NAME=ncurses
MAJOR=6
MINOR=5
PATCH=20251206
VERSION=6.5-20251206

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/ThomasDickey/ncurses-snapshots/archive/refs/tags/v${MAJOR}_${MINOR}_${PATCH}.tar.gz

gzip -cd v${MAJOR}_${MINOR}_${PATCH}.tar.gz | tar -x
cd ncurses-snapshots-${MAJOR}_${MINOR}_${PATCH}

./configure \
	--prefix=/usr \
	--with-shared \
	--with-normal \
	--with-pkg-config-libdir=/usr/lib/pkgconfig \
	--with-termlib \
	--with-cxx-binding \
	--enable-pc-files \
	--enable-widec \
	--enable-stripping \
	--without-debug \
	--without-tests

make
make DESTDIR=$DESTDIR install

# See www.linuxfromscratch.org/lfs/view/development/chapter08/ncurses.html
sed -e 's/^#if.*XOPEN.*$/#if 1/' "$DESTDIR/usr/include/curses.h" > "$DESTDIR/usr/include/curses.h.new" 
mv "$DESTDIR/usr/include/curses.h.new" "$DESTDIR/usr/include/curses.h"

for lib in ncurses form panel menu
do
	ln -sf lib${lib}w.so "$DESTDIR/usr/lib/lib${lib}.so"
	ln -sf lib${lib}w.a  "$DESTDIR/usr/lib/lib${lib}.a"
	ln -sf ${lib}w.pc    "$DESTDIR/usr/lib/pkgconfig/${lib}.pc"
done

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-ncurses@$VERSION.tar.gz"
doas rm -rf $DESTDIR
