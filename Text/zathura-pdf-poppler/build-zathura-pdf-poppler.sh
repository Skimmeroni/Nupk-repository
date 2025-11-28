#!/bin/sh -e

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

muon setup \
	-D prefix=/usr \
	-D buildtype=release \
	build

ninja -C build
muon -C build install -d $DESTDIR

strip --strip-unneeded $DESTDIR/usr/lib/zathura/libpdf-poppler.so

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Text-zathura-pdf-poppler@$VERSION.tar.gz"
doas rm -rf $DESTDIR
