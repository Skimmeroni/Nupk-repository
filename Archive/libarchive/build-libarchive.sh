#!/bin/sh -e

PRETTY_NAME=libarchive
MAJOR=3
MINOR=8
PATCH=2
VERSION=3.8.2

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://libarchive.org/downloads/libarchive-$VERSION.tar.xz

xz -cd libarchive-$VERSION.tar.xz | tar -x
cd libarchive-$VERSION

./configure \
	--prefix=/usr \
	--without-openssl \
	--without-expat \
	--without-xml2 \
	--without-lz4 \
	--without-zstd \
	--without-nettle \
	--with-bz2lib \
	--with-zlib \
	--with-lzma \
	--enable-static

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/man/man3"
find $DESTDIR -type f -name '*.la' -delete

install -Dm644 COPYING "$DESTDIR/usr/share/LICENSES/libarchive.license" 

ln -sf bsdcpio  "$DESTDIR/usr/bin/cpio"
ln -sf bsdtar   "$DESTDIR/usr/bin/tar"
ln -sf bsdunzip "$DESTDIR/usr/bin/unzip"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../libarchive@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
