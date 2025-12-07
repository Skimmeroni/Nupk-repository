#!/bin/sh

set -eu

PRETTY_NAME=libedit
MAJOR=20251016
MINOR=3
PATCH=1
VERSION=20251016.3.1

# The versioning scheme is probably incorrect

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://www.thrysoee.dk/editline/libedit-$MAJOR-$MINOR.$PATCH.tar.gz

gzip -cd libedit-$MAJOR-$MINOR.$PATCH.tar.gz | tar -x
cd libedit-$MAJOR-$MINOR.$PATCH

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-libedit@$VERSION.tar.gz"
doas rm -rf $DESTDIR
