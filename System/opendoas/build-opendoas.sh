#!/bin/sh -e

PRETTY_NAME=opendoas
MAJOR=6
MINOR=8
PATCH=2
VERSION=6.8.2

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

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

install -Dm755 doas $DESTDIR/usr/bin/doas
install -Dm644 doas.1 $DESTDIR/usr/share/man/man1/doas.1
install -Dm644 ../doas.conf $DESTDIR/etc/doas.conf
install -Dm644 LICENSE $DESTDIR/usr/share/LICENSES/opendoas.license

strip --strip-unneeded $DESTDIR/usr/bin/doas
chmod u+s $DESTDIR/usr/bin/doas

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../opendoas@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
