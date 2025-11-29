#!/bin/sh -e

PRETTY_NAME=fonts:noto-emoji
MAJOR=2
MINOR=051
PATCH=
VERSION=2.051

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://github.com/googlefonts/noto-emoji/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd noto-emoji-$VERSION

install -Dm644 -t "$DESTDIR/usr/share/fonts/TTF" fonts/NotoColorEmoji.ttf
install -Dm644 LICENSE "$DESTDIR/usr/share/LICENSES/noto-emoji.license"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Fonts-noto-emoji@$VERSION.tar.gz"
doas rm -rf $DESTDIR

printf "\033[1mYou have to run fc-cache for the font to be available!\033[0m\n"
# doas fc-cache -f
