#!/bin/sh

set -eu

### MARKED FOR REMOVAL ###

PRETTY_NAME=zathura-pdf-mupdf
MAJOR=0
MINOR=4
PATCH=6
VERSION=0.4.6

DESTDIR="$PWD/temporary-builddir"
[ -d $DESTDIR ] || mkdir temporary-builddir

curl --location --remote-name --skip-existing https://github.com/pwmt/zathura-pdf-mupdf/archive/$VERSION.tar.gz
curl --location --remote-name --skip-existing https://codeberg.org/kiss-community/community/raw/branch/main/community/zathura-pdf-mupdf/patches/remove-mupdf-linking-detection.patch

gzip -cd $VERSION.tar.gz | tar -x
cd zathura-pdf-mupdf-$VERSION

# Zathura-pdf-mupdf still looks for mupdf split libraries, which isn't a thing anymore
patch -p1 < ../remove-mupdf-linking-detection.patch

muon setup \
	-D prefix=/usr \
	-D buildtype=release \
	build

ninja -C build
muon -C build install -d $DESTDIR

strip --strip-unneeded $DESTDIR/usr/lib/zathura/libpdf-mupdf.so

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-zathura-pdf-mupdf@$VERSION.tar.gz"
doas rm -rf $DESTDIR
