#!/bin/sh -e

PRETTY_NAME=nupk
MAJOR=
MINOR=
PATCH=
VERSION=git

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

git clone https://github.com/Skimmeroni/Nupk.git
install -Dm755 -t "$DESTDIR/usr/bin" nupk.git/nupk

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Base-nupk@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
