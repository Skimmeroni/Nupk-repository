#!/bin/sh -e

PRETTY_NAME=jq
MAJOR=1
MINOR=8
PATCH=1
VERSION=1.8.1

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://github.com/stedolan/jq/releases/download/jq-$VERSION/jq-$VERSION.tar.gz

gzip -cd jq-$VERSION.tar.gz | tar -x
cd jq-$VERSION

./configure \
	--prefix=/usr \
	--disable-maintainer-mode \
	--with-oniguruma=no

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/doc"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../jq@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
