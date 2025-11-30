#!/bin/sh -e

PRETTY_NAME=fonts:jetbrains-mono
MAJOR=2
MINOR=304
PATCH=
VERSION=2.304

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/JetBrains/JetBrainsMono/releases/download/v$VERSION/JetBrainsMono-$VERSION.zip

unzip JetBrainsMono-$VERSION.zip

find fonts/ttf      -type f -name '*.ttf'   -exec install -Dm644 -t $DESTDIR/usr/share/fonts/TTF   {} \;
find fonts/webfonts -type f -name '*.woff2' -exec install -Dm644 -t $DESTDIR/usr/share/fonts/WOFF2 {} \;
install -Dm644 OFL.txt "$DESTDIR/usr/share/LICENSES/jetbrains-mono.license"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > Fonts-jetbrains-mono@$VERSION.tar.gz"
doas rm -rf $DESTDIR

printf "\033[1mYou have to run fc-cache for the font to be available!\033[0m\n"
# doas fc-cache -f
