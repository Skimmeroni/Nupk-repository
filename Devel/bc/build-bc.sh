#!/bin/sh -e

# TODO: phase out in favour of Toybox bc

PRETTY_NAME=bc-gh
MAJOR=7
MINOR=1
PATCH=0
VERSION=7.1.0

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://github.com/gavinhoward/bc/releases/download/$VERSION/bc-$VERSION.tar.gz

gzip -cd bc-$VERSION.tar.gz | tar -x
cd bc-$VERSION

./configure \
	--prefix=/usr \
	--enable-editline \
	--disable-nls \
	--disable-generated-tests \
	--disable-problematic-tests

make
make DESTDIR=$DESTDIR install

find "$DESTDIR/usr/bin" -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../bc@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
