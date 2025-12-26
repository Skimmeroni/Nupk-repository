#!/bin/sh

set -eu

PRETTY_NAME=librsvg
MAJOR=2
MINOR=61
PATCH=3
VERSION=2.61.3

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://download.gnome.org/sources/librsvg/$MAJOR.$MINOR/librsvg-$VERSION.tar.xz

xz -cd librsvg-$VERSION.tar.xz | tar -x
cd librsvg-$VERSION

# TODO: why does this have to be specified?
export CARGO_HTTP_CAINFO="/etc/ssl/cert.pem"

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D strip=true \
	-D tests=false \
	-D avif=disabled \
	-D rsvg-convert=disabled \
	-D introspection=disabled \
	-D pixbuf=enabled \
	-D pixbuf-loader=enabled \
	-D docs=disabled \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

rm -rf "$DESTDIR/usr/share"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-librsvg@$VERSION.tar.gz"
doas rm -rf $DESTDIR

printf "\033[1mRemember to update the loaders cache!\033[0m\n"                                                                                                                            
# doas gdk-pixbuf-query-loaders --update-cache
