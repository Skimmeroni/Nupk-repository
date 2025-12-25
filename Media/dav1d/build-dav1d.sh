#!/bin/sh

set -eu

PRETTY_NAME=dav1d
MAJOR=1
MINOR=5
PATCH=1
VERSION=1.5.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://downloads.videolan.org/pub/videolan/dav1d/$VERSION/dav1d-$VERSION.tar.xz

xz -cd dav1d-$VERSION.tar.xz | tar -x
cd dav1d-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D wrap_mode=nofallback \
	-D default_library=both \
	-D strip=true \
	-D enable_tools=false \
	-D enable_examples=false \
	-D enable_tests=false \
	-D enable_docs=false \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-dav1d@$VERSION.tar.gz"
doas rm -rf $DESTDIR
