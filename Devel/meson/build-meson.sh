#!/bin/sh -e

PRETTY_NAME=meson
MAJOR=1
MINOR=9
PATCH=1
VERSION=1.9.1

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://github.com/mesonbuild/meson/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd meson-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

rm -rf $DESTDIR/usr/share/polkit-1

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../meson@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
