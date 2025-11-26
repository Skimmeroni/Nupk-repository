#!/bin/sh -e

PRETTY_NAME=lynx
MAJOR=2
MINOR=9
PATCH=2
VERSION=2.9.2

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://invisible-mirror.net/archives/lynx/tarballs/lynx$VERSION.tar.bz2

bzip2 -cd lynx$VERSION.tar.bz2 | tar -x
cd lynx$VERSION

./configure \
	--prefix=/usr \
	--sysconfdir=/etc/lynx \
	--disable-dired \
	--without-brotli \
	--without-bzlib \
	--without-zlib \
	--with-ssl

make
make DESTDIR=$DESTDIR install

strip --strip-unneeded $DESTDIR/usr/bin/lynx

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Net-lynx@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
