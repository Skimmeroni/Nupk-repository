#!/bin/sh

set -eu

PRETTY_NAME=flex
MAJOR=2
MINOR=6
PATCH=4
VERSION=2.6.4

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/westes/flex/releases/download/v/flex-$VERSION.tar.gz

gzip -cd flex-$VERSION.tar.gz | tar -x
cd flex-$VERSION

./configure \
	--prefix=/usr \
	ac_cv_func_malloc_0_nonnull=yes \
	ac_cv_func_realloc_0_nonnull=yes

make
make DESTDIR=$DESTDIR install-strip

ln -sf flex "$DESTDIR/usr/bin/lex"

rm -rf "$DESTDIR/usr/share/doc"
rm -rf "$DESTDIR/usr/share/info"

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-flex@$VERSION.tar.gz"
doas rm -rf $DESTDIR
