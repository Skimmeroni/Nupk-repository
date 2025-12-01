#!/bin/sh

set -eu

PRETTY_NAME=ca-certificates
MAJOR=2025
MINOR=11
PATCH=04
VERSION=20251104

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl https://curl.se/ca/cacert-${MAJOR}-${MINOR}-${PATCH}.pem > cert.pem
install -Dm644 cert.pem "$DESTDIR/etc/ssl/cert.pem"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > Net-ca-certificates@$VERSION.tar.gz"
doas rm -rf $DESTDIR
