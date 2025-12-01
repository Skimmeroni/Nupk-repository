#!/bin/sh

set -eu

PRETTY_NAME=opendoas
MAJOR=6
MINOR=8
PATCH=2
VERSION=6.8.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/Duncaen/OpenDoas/archive/v$VERSION.tar.gz

tar -xf v$VERSION.tar.gz
cd OpenDoas-$VERSION

./configure \
    --prefix=/usr \
    --enable-static \
    --with-shadow \
    --with-timestamp \
    --without-pam

make

install -Dm755 doas "$DESTDIR/usr/bin/doas"
install -Dm644 doas.1 "$DESTDIR/usr/share/man/man1/doas.1"
install -Dm644 ../doas.conf "$DESTDIR/etc/doas.conf"
install -Dm644 LICENSE "$DESTDIR/usr/share/LICENSES/opendoas.license"
strip --strip-unneeded "$DESTDIR/usr/bin/doas"
chmod u+s "$DESTDIR/usr/bin/doas"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-opendoas@$VERSION.tar.gz"
doas rm -rf $DESTDIR
