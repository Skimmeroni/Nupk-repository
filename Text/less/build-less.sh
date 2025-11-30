#!/bin/sh -e

PRETTY_NAME=less
MAJOR=6
MINOR=6
PATCH=8
VERSION=668

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing http://www.greenwoodsoftware.com/less/less-$VERSION.tar.gz

gzip -cd less-$VERSION.tar.gz | tar -x
cd less-$VERSION

./configure --prefix=/usr

make
make DESTDIR=$DESTDIR install-strip

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-less@$VERSION.tar.gz"
doas rm -rf $DESTDIR
