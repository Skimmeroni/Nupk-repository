#!/bin/sh -e

PRETTY_NAME=fonts:roboto
MAJOR=2
MINOR=138
PATCH=
VERSION=2.138

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://github.com/googlefonts/roboto/releases/download/v/roboto-android.zip
mkdir build
unzip -d build roboto-android.zip

mkdir -p "$DESTDIR/usr/share/fonts/TTF"
cp build/*.ttf "$DESTDIR/usr/share/fonts/TTF"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../ttf-roboto@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
