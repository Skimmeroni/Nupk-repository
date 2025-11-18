#!/bin/sh -e

PRETTY_NAME=autoconf
MAJOR=2
MINOR=72
PATCH=
VERSION=2.72

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://ftp.gnu.org/gnu/autoconf/autoconf-$VERSION.tar.xz

xz -cd autoconf-$VERSION.tar.xz | tar -x
cd autoconf-$VERSION

./configure --prefix=/usr

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/info"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../autoconf@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
