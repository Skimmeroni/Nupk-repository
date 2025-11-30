#!/bin/sh -e

PRETTY_NAME=consolation
MAJOR=0
MINOR=0
PATCH=10
VERSION=0.0.10

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://deb.debian.org/debian/pool/main/c/consolation/consolation_$VERSION.orig.tar.xz

xz -cd consolation_$VERSION.orig.tar.xz | tar -x
cd consolation-$VERSION

./configure --prefix=/usr --sbindir=/usr/bin
make
make DESTDIR=$DESTDIR install-strip

# man-pages require help2man
rm -rf $DESTDIR/usr/share/man
install -Dm644 LICENSE $DESTDIR/usr/share/LICENSES/consolation.license

install -Dm755 ../consolation.run "$DESTDIR/etc/sv/consolation/run"
ln -sf /run/runit/supervise.consolation "$DESTDIR/etc/sv/consolation/supervise"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-consolation@$VERSION.tar.gz"
doas rm -rf $DESTDIR
