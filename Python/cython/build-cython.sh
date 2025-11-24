#!/bin/sh -e

PRETTY_NAME=python:cython
MAJOR=3
MINOR=2
PATCH=1
VERSION=3.2.1

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/cython/cython/releases/download/$VERSION/Cython-$VERSION.tar.gz

gzip -cd Cython-$VERSION.tar.gz | tar -x
cd cython-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

find "$DESTDIR/usr/lib" -type f -name '*.so' -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Python-cython@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
