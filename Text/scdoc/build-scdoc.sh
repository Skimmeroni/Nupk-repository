#!/bin/sh -e

PRETTY_NAME=scdoc
MAJOR=1
MINOR=11
PATCH=4
VERSION=1.11.4

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://git.sr.ht/~sircmpwn/scdoc/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd scdoc-$VERSION

make PREFIX=/usr PCDIR=/usr/lib/pkgconfig
make PREFIX=/usr PCDIR=/usr/lib/pkgconfig DESTDIR=$DESTDIR install

strip --strip-unneeded "$DESTDIR/usr/bin/scdoc"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Text-scdoc@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
