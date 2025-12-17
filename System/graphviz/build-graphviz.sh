#!/bin/sh

set -eu

PRETTY_NAME=graphviz
MAJOR=14
MINOR=1
PATCH=1
VERSION=14.1.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/$VERSION/graphviz-$VERSION.tar.xz

xz -cd graphviz-$VERSION.tar.xz | tar -x
cd graphviz-$VERSION

# TODO: svg?
# Note: disabling GD disables output in raster formats, which
# we do not care about anyway
./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static \
	--enable-swig \
	--disable-man-pdfs \
	--disable-debug \
	--with-expat \
	--with-poppler \
	--with-pangocairo \
	--with-freetype2 \
	--without-gdk \
	--without-gdk-pixbuf \
	--without-gtk \
	--without-gtkgl \
	--without-gtkglext \
	--without-rsvg \
	--without-webp \
	--without-libgd

make
make DESTDIR=$DESTDIR install-strip

find "$DESTDIR" -type f -name '*.la' -delete

rm -rf "$DESTDIR/usr/share/doc"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-graphviz@$VERSION.tar.gz"
doas rm -rf $DESTDIR

printf "\033[1mRemember to register graphviz plugins!\033[0m\n"
# doas dot -c
