#!/bin/sh -e

PRETTY_NAME=curl
MAJOR=8
MINOR=17
PATCH=0
VERSION=8.17.0

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://curl.haxx.se/download/curl-$VERSION.tar.xz

xz -cd curl-$VERSION.tar.xz | tar -x
cd curl-$VERSION

./configure \
	--prefix=/usr \
	--enable-ipv6 \
	--enable-manual \
	--enable-symbol-hiding \
	--enable-unix-sockets \
	--disable-docs \
	--disable-ldap \
	--disable-ares \
	--with-openssl \
	--with-pic \
	--with-ca-fallback \
	--without-librtmp \
	--without-libpsl \
	--without-libidn2 \
	--without-brotli \
	--without-zstd

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share"

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Net-curl@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
