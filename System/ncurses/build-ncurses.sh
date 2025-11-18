#!/bin/sh -e

PRETTY_NAME=netbsd-curses
MAJOR=0
MINOR=3
PATCH=2
VERSION=0.3.2

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://github.com/sabotage-linux/netbsd-curses/archive/refs/tags/v$VERSION.tar.gz
gzip -cd v$VERSION.tar.gz | tar -x
cd netbsd-curses-$VERSION

make PREFIX=/usr all
make PREFIX=/usr DESTDIR=$DESTDIR install

ln -sf libterminfo.so "$DESTDIR/usr/lib/libtinfo.so"
ln -sf libterminfo.a  "$DESTDIR/usr/lib/libtinfo.a"

rm -rf "$DESTDIR/usr/share/man/man3"

find "$DESTDIR/usr/bin" ! -name 'clear' -type f -exec strip --strip-unneeded {} \;
find "$DESTDIR" -name '*.a' -type f -exec strip --strip-unneeded {} \;
find "$DESTDIR" -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../ncurses@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
