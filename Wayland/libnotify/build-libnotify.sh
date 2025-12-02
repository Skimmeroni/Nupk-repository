#!/bin/sh

set -eu

PRETTY_NAME=libnotify
MAJOR=0
MINOR=8
PATCH=7
VERSION=0.8.7

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://download.gnome.org/sources/libnotify/$MAJOR.$MINOR/libnotify-$VERSION.tar.xz

xz -cd libnotify-$VERSION.tar.xz | tar -x
cd libnotify-$VERSION

# -D default_library=both doesn't do anything
muon setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D wrap_mode=nofallback \
	-D tests=false \
	-D gtk_doc=false \
	-D man=false \
	-D introspection=disabled \
	-D docbook_docs=disabled \
	build

ninja -C build
muon -C build install -d $DESTDIR

find "$DESTDIR/usr/lib" -type f -name '*.a'   -exec strip --strip-unneeded {} \;
find "$DESTDIR/usr/lib" -type f -name '*.so*' -exec strip --strip-unneeded {} \;
strip --strip-unneeded "$DESTDIR/usr/bin/notify-send"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-libnotify@$VERSION.tar.gz"
doas rm -rf $DESTDIR
