#!/bin/sh -e

PRETTY_NAME=fonts:libertinus
MAJOR=7
MINOR=051
PATCH=
VERSION=7.051

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/alerque/libertinus/releases/download/v$VERSION/Libertinus-$VERSION.zip

unzip Libertinus-$VERSION.zip
cd Libertinus-$VERSION

find . -type f -name '*.otf'   -exec install -Dm644 -t $DESTDIR/usr/share/fonts/OTF   {} \;
find . -type f -name '*.ttf'   -exec install -Dm644 -t $DESTDIR/usr/share/fonts/TTF   {} \;
find . -type f -name '*.woff2' -exec install -Dm644 -t $DESTDIR/usr/share/fonts/WOFF2 {} \;
install -Dm644 OFL.txt "$DESTDIR/usr/share/LICENSES/libertinus.license"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Fonts-libertinus@$VERSION.tar.gz"
doas rm -rf $DESTDIR

printf "\033[1mYou have to run fc-cache for the font to be available!\033[0m\n"
# doas fc-cache -f
