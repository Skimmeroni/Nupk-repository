#!/bin/sh -e

PRETTY_NAME=jq
MAJOR=1
MINOR=8
PATCH=1
VERSION=1.8.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

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
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-jq@$VERSION.tar.gz"
doas rm -rf $DESTDIR
