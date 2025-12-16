#!/bin/sh

set -eu

PRETTY_NAME=freeciv
MAJOR=3
MINOR=2
PATCH=1
VERSION=3.2.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/freeciv/freeciv/archive/refs/tags/R${MAJOR}_${MINOR}_${PATCH}.tar.gz

gzip -cd R${MAJOR}_${MINOR}_${PATCH}.tar.gz | tar -x
cd freeciv-R${MAJOR}_${MINOR}_${PATCH}

# TODO: imagemagick?
# Note: there is a meson backend, but it's experimental
./autogen.sh \
	--prefix=/usr \
	--enable-shared \
	--enable-static \
	--enable-client=gtk3.22 \
	--enable-fcdb=sqlite3 \
	--enable-fcmp=cli \
	--enable-server \
	--enable-sys-lua \
	--with-liblzma \
	--disable-debug \
	--disable-fcweb \
	--disable-freeciv-manual \
	--disable-freeciv-ruleup \
	--disable-json \
	--disable-mapimg \
	--disable-nls \
	--disable-ruledit \
	--disable-sdl-mixer \
	--without-desktopdir \
	--without-metainfodir \
	--without-libbz2 \
	--without-libzstd \
	--without-readline

make
make DESTDIR=$DESTDIR install-strip

mkdir -p "$DESTDIR/usr/share/LICENSES"
mv "$DESTDIR/usr/share/doc/freeciv/COPYING" "$DESTDIR/usr/share/LICENSES/freeciv.license"

rm -rf "$DESTDIR/usr/share/doc"
rm -rf "$DESTDIR/usr/share/icons"
rm -rf "$DESTDIR/usr/share/pixmaps"

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Misc-freeciv@$VERSION.tar.gz"
doas rm -rf $DESTDIR
