#!/bin/sh -e

PRETTY_NAME=ca-certificates
MAJOR=2025
MINOR=11
PATCH=04
VERSION=20251104

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl https://curl.se/ca/cacert-${MAJOR}-${MINOR}-${PATCH}.pem > cert.pem
install -Dm644 cert.pem "$DESTDIR/etc/ssl/cert.pem"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ca-certificates@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
