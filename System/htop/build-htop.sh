#!/bin/sh -e

PRETTY_NAME=htop
MAJOR=3
MINOR=4
PATCH=1
VERSION=3.4.1

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://github.com/htop-dev/htop/releases/download/$VERSION/htop-$VERSION.tar.xz

xz -cd htop-$VERSION.tar.xz | tar -x
cd htop-$VERSION

./configure \
	--prefix=/usr \
	--sysconfdir=/etc \
	--disable-unicode

make
make DESTDIR=$DESTDIR install-strip

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../htop@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
