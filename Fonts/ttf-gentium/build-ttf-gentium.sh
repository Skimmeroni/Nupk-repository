#!/bin/sh -e

PRETTY_NAME=fonts:gentium
MAJOR=7
MINOR=000
PATCH=
VERSION=7.000

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://software.sil.org/downloads/r/gentium/Gentium-$VERSION.zip

unzip Gentium-$VERSION.zip
cd Gentium-$VERSION

find . -type f -name '*.ttf'   -exec install -Dm644 -t $DESTDIR/usr/share/fonts/TTF   {} \;
find . -type f -name '*.woff2' -exec install -Dm644 -t $DESTDIR/usr/share/fonts/WOFF2 {} \;
install -Dm644 OFL.txt "$DESTDIR/usr/share/LICENSES/ttf-gentium.license"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../ttf-gentium@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
