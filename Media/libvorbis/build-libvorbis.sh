#!/bin/sh -e

PRETTY_NAME=libvorbis
MAJOR=1
MINOR=3
PATCH=7
VERSION=1.3.7

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/xiph/vorbis/releases/download/v$VERSION/libvorbis-$VERSION.tar.xz

xz -cd libvorbis-$VERSION.tar.xz | tar -x
cd libvorbis-$VERSION

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static \
	--disable-oggtest \
	--disable-docs \
	--disable-examples

make
make DESTDIR=$DESTDIR -C include install
make DESTDIR=$DESTDIR install-strip
make DESTDIR=$DESTDIR install-m4dataDATA
make DESTDIR=$DESTDIR install-pkgconfigDATA

# ?????????????
rm -rf $DESTDIR/usr/share/doc
find $DESTDIR -type f -name '*.la' -delete 

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Media-libvorbis@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
