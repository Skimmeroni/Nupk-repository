#!/bin/sh -e

# Taken one to one from KISS, with the compose-only patch slightly modified
# It would be interesting to bypass the config entirely and install
# tables straight away

PRETTY_NAME=libx11
MAJOR=1
MINOR=8
PATCH=12
VERSION=1.8.12

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://x.org/releases/individual/lib/libX11-$VERSION.tar.xz

xz -cd libX11-$VERSION.tar.xz | tar -x
cd libX11-$VERSION

patch -p1 < ../compose-only.patch

./configure \
	--prefix=/usr \
	--disable-specs \
	--disable-xkb \
	--without-fop \
	--without-xmlto

make -C nls
make DESTDIR=$DESTDIR -C nls install

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Wayland-compose-tables@$VERSION.tar.gz"
doas rm -rf $DESTDIR
