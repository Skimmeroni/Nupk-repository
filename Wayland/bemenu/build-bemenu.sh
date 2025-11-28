#!/bin/sh -e

PRETTY_NAME=bemenu
MAJOR=0
MINOR=6
PATCH=23
VERSION=0.6.23

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://github.com/Cloudef/bemenu/releases/download/$VERSION/bemenu-$VERSION.tar.gz

gzip -cd bemenu-$VERSION.tar.gz | tar -x
cd bemenu-$VERSION

make PREFIX=/usr clients wayland
make PREFIX=/usr DESTDIR=$DESTDIR install

strip --strip-unneeded $DESTDIR/usr/bin/bemenu
strip --strip-unneeded $DESTDIR/usr/bin/bemenu-run
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Wayland-bemenu@$VERSION.tar.gz"
doas rm -rf $DESTDIR
