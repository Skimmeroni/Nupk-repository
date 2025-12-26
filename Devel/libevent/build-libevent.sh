#!/bin/sh

set -eu

PRETTY_NAME=libevent
MAJOR=2
MINOR=2
PATCH=1
VERSION=2.2.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/libevent/libevent/releases/download/release-$VERSION-alpha/libevent-$VERSION-alpha-dev.tar.gz

gzip -cd libevent-$VERSION-alpha-dev.tar.gz | tar -x
cd libevent-$VERSION-alpha-dev

cmake -B build \
	-D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D EVENT__LIBRARY_TYPE=BOTH \
	-D EVENT__DISABLE_DEBUG_MODE=YES \
	-D EVENT__DISABLE_MBEDTLS=YES \
	-D EVENT__DISABLE_MM_REPLACEMENT=YES \
	-D EVENT__DISABLE_OPENSSL=NO \
	-G Ninja

cmake --build build --verbose
DESTDIR=$DESTDIR cmake --install build --strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-libevent@$VERSION.tar.gz"
doas rm -rf $DESTDIR
