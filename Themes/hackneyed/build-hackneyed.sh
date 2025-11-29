#!/bin/sh -e

PRETTY_NAME=xcursor-hackneyed
MAJOR=0
MINOR=9
PATCH=
VERSION=0.9

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://gitlab.com/Enthymeme/hackneyed-x11-cursors/uploads/878aa3d33e874ef4264079ea857a66f8/Hackneyed-$VERSION-right-handed.tar.bz2

bzip2 -cd Hackneyed-$VERSION-right-handed.tar.bz2 | tar -x

install -Dm644 -t "$DESTDIR/usr/share/icons/Hackneyed" Hackneyed/index.theme 
cp -r Hackneyed/cursors "$DESTDIR/usr/share/icons/Hackneyed" 

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > Themes-hackneyed@$VERSION.tar.gz"
doas rm -rf $DESTDIR
