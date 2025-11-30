#!/bin/sh -e

PRETTY_NAME=mime-types
MAJOR=
MINOR=
PATCH=
VERSION=git

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types | grep -v '#' - > mime.types

install -Dm644 mime.types "$DESTDIR/etc/mime.types"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > Base-mime-types@$VERSION.tar.gz"
doas rm -rf $DESTDIR
