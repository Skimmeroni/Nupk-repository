#!/bin/sh

set -eu

PRETTY_NAME=geany
MAJOR=2
MINOR=1
PATCH=
VERSION=2.1

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://download.geany.org/geany-$VERSION.tar.gz

gzip -cd geany-$VERSION.tar.gz | tar -x
cd geany-$VERSION

# There seems to be a problem in installing the desktop file,
# I'm assuming related to gettext.
# TODO: instead of eviscerating the desktop file straight away,
# a better solution would be to generate it manually
patch -p1 < ../dont-install-desktop-file.patch

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static \
	--enable-plugins \
	--disable-html-docs \
	--disable-pdf-docs \
	--disable-api-docs \
	--disable-gtkdoc-header \
	--disable-vte

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

rm -rf "$DESTDIR/usr/share/locale"
rm -rf "$DESTDIR/usr/share/doc"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-geany@$VERSION.tar.gz"
doas rm -rf $DESTDIR
