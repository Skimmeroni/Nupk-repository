#!/bin/sh -e

PRETTY_NAME=sqlite
MAJOR=3
MINOR=51
PATCH=1
VERSION=3.51.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://sqlite.org/2025/sqlite-autoconf-${MAJOR}${MINOR}0${PATCH}00.tar.gz

gzip -cd sqlite-autoconf-${MAJOR}${MINOR}0${PATCH}00.tar.gz | tar -x
cd sqlite-autoconf-${MAJOR}${MINOR}0${PATCH}00

export CPPFLAGS="$CPPFLAGS -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_ENABLE_COLUMN_METADATA"

./configure \
	--prefix=/usr \
	--enable-math \
	--enable-load-extension \
	--enable-editline \
	--enable-fts3 \
	--enable-fts4 \
	--enable-fts5 \
	--enable-shared \
	--enable-static \
	--editline \
	--disable-debug

make
make DESTDIR=$DESTDIR install

find $DESTDIR -type f -name '*.la' -delete

strip --strip-unneeded "$DESTDIR/usr/bin/sqlite3"
find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-sqlite@$VERSION.tar.gz"
doas rm -rf $DESTDIR
