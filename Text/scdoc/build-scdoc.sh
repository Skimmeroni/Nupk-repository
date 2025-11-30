#!/bin/sh -e

PRETTY_NAME=scdoc
MAJOR=1
MINOR=11
PATCH=4
VERSION=1.11.4

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://git.sr.ht/~sircmpwn/scdoc/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd scdoc-$VERSION

make PREFIX=/usr PCDIR=/usr/lib/pkgconfig
make PREFIX=/usr PCDIR=/usr/lib/pkgconfig DESTDIR=$DESTDIR install

strip --strip-unneeded "$DESTDIR/usr/bin/scdoc"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-scdoc@$VERSION.tar.gz"
doas rm -rf $DESTDIR
