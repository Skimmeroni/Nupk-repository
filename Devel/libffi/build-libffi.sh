#!/bin/sh

set -eu

PRETTY_NAME=libffi
MAJOR=3
MINOR=5
PATCH=2
VERSION=3.5.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/libffi/libffi/releases/download/v$VERSION/libffi-$VERSION.tar.gz

gzip -cd libffi-$VERSION.tar.gz | tar -x
cd libffi-$VERSION

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static \
	--disable-docs \
	--disable-debug

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share"
find $DESTDIR -type f -name '*.la' -delete

# TODO: find a way to avoid having to do this by hand, since
# this doesn't seem to be reliable
if [ -d "$DESTDIR/usr/lib64" ]
then
	mv "$DESTDIR/usr/lib64/"* "$DESTDIR/usr/lib"
	rmdir "$DESTDIR/usr/lib64"
	sed 's|lib64|lib|g' "$DESTDIR/usr/lib/pkgconfig/libffi.pc" > "$DESTDIR/usr/lib/pkgconfig/libffi.pc.new"
	mv "$DESTDIR/usr/lib/pkgconfig/libffi.pc.new" "$DESTDIR/usr/lib/pkgconfig/libffi.pc"
fi

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-libffi@$VERSION.tar.gz"
doas rm -rf $DESTDIR
