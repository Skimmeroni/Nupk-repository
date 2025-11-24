#!/bin/sh -e

PRETTY_NAME=mime-types
MAJOR=
MINOR=
PATCH=
VERSION=git

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl https://svn.apache.org/repos/asf/httpd/httpd/trunk/docs/conf/mime.types | grep -v '#' - > mime.types

install -Dm644 mime.types "$DESTDIR/etc/mime.types"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > Base-mime-types@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
