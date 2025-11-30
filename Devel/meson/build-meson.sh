#!/bin/sh -e

PRETTY_NAME=meson
MAJOR=1
MINOR=9
PATCH=1
VERSION=1.9.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/mesonbuild/meson/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd meson-$VERSION

gpep517 install-from-source --optimize all --destdir $DESTDIR

rm -rf $DESTDIR/usr/share/polkit-1

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-meson@$VERSION.tar.gz"
doas rm -rf $DESTDIR
