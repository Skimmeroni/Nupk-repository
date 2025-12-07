#!/bin/sh

set -eu

PRETTY_NAME=zathura-pdf-poppler
MAJOR=0
MINOR=3
PATCH=4
VERSION=0.3.4

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://github.com/pwmt/zathura-pdf-poppler/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd zathura-pdf-poppler-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D strip=true \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-zathura-pdf-poppler@$VERSION.tar.gz"
doas rm -rf $DESTDIR
