#!/bin/sh

set -eu

PRETTY_NAME=alsa-ucm-conf
MAJOR=1
MINOR=2
PATCH=15.1
VERSION=1.2.15.1

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://www.alsa-project.org/files/pub/lib/alsa-ucm-conf-$VERSION.tar.bz2

bzip2 -cd alsa-ucm-conf-$VERSION.tar.bz2 | tar -x
cd alsa-ucm-conf-$VERSION

mkdir -p "$DESTDIR/usr/share/alsa"
cp -r ucm "$DESTDIR/usr/share/alsa"
cp -r ucm2 "$DESTDIR/usr/share/alsa"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-alsa-ucm-conf@$VERSION.tar.gz"
doas rm -rf $DESTDIR
