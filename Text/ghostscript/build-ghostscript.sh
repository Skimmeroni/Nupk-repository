#!/bin/sh -e

PRETTY_NAME=ghostscript
MAJOR=10
MINOR=06
PATCH=0
VERSION=10.06.0

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs${MAJOR}${MINOR}${PATCH}/ghostscript-$VERSION.tar.gz

gzip -cd ghostscript-$VERSION.tar.gz | tar -x
cd ghostscript-$VERSION

# Ensure that no bundled library is preferred over system libaries
rm -rf cups freetype ijs jbig2dec jpeg lcms2mt leptonica libpng openjpeg tesseract tiff zlib 

# --without-local-brotli doesn't actually work
./configure \
	--prefix=/usr \
	--with-jbig2dec \
	--with-libtiff \
	--with-system-libtiff \
	--with-local-brotli \
	--with-drivers=ALL \
	--without-tesseract \
	--without-ijs \
	--without-x \
	--without-libidn \
	--without-libpaper \
	--enable-fontconfig \
	--enable-freetype \
	--enable-openjpeg \
	--disable-cups \
	--disable-gtk \
	--disable-dbus

make
make DESTDIR=$DESTDIR install

rm -rf "$DESTDIR/usr/share/doc"
strip --strip-unneeded $DESTDIR/usr/bin/gs

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Text-ghostscript@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
