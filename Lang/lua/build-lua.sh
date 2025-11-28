#!/bin/sh -e

PRETTY_NAME=lua
MAJOR=5
MINOR=4
PATCH=8
VERSION=5.4.8

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://www.lua.org/ftp/lua-$VERSION.tar.gz

gzip -cd lua-$VERSION.tar.gz | tar -x
cd lua-$VERSION

patch -p1 < ../no-versioning.patch

make CC="$CC" \
     MYCFLAGS="$CFLAGS" \
     MYLDFLAGS="$LDFLAGS" \
     posix

make INSTALL_TOP="$DESTDIR/usr" \
     INSTALL_MAN="$DESTDIR/usr/share/man/man1" \
     INSTALL_DATA="cp -P" \
     install

sed "s|@VERSION@|$VERSION|" ../lua.pc.stub > ../lua.pc
install -Dm644 -t "$DESTDIR/usr/lib/pkgconfig" ../lua.pc

strip --strip-unneeded $DESTDIR/usr/bin/lua
strip --strip-unneeded $DESTDIR/usr/bin/luac
strip --strip-unneeded $DESTDIR/usr/lib/liblua.a

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Lang-lua@$VERSION.tar.gz"
doas rm -rf $DESTDIR
