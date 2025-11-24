#!/bin/sh -e

PRETTY_NAME=pkgconf
MAJOR=2
MINOR=5
PATCH=0
VERSION=2.5.1

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://distfiles.ariadne.space/pkgconf/pkgconf-$VERSION.tar.xz

xz -cd pkgconf-$VERSION.tar.xz | tar -x
cd pkgconf-$VERSION

./configure \
	--prefix=/usr \
	--sysconfdir=/etc
	
make
make DESTDIR=$DESTDIR install-strip

ln -s pkgconf "$DESTDIR/usr/bin/pkg-config"

rm -rf "$DESTDIR/usr/share/doc"
find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Devel-pkgconf@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
