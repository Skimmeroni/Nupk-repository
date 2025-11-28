#!/bin/sh -e

PRETTY_NAME=muon-meson
MAJOR=0
MINOR=5
PATCH=0
VERSION=0.5.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://git.sr.ht/~lattis/muon/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd muon-$VERSION

# Sligthly adapted from the excellent building script found in the AUR

export CFLAGS="-DBOOTSTRAP_NO_SAMU"
./bootstrap.sh build-stage1

./build-stage1/muon-bootstrap setup \
	-D libarchive=disabled \
	-D libcurl=disabled \
	-D libpkgconf=enabled \
	-D man-pages=disabled \
	-D meson-docs=disabled \
	-D meson-tests=disabled \
	-D readline=bestline \
	-D samurai=disabled \
	-D tracy=disabled \
	-D ui=disabled \
	-D website=disabled \
	build-stage2
ninja -C build-stage2

./build-stage2/muon setup \
	-D prefix=/usr \
	-D libarchive=enabled \
	-D libcurl=enabled \
	-D libpkgconf=enabled \
	-D man-pages=enabled \
	-D meson-docs=disabled \
	-D readline=bestline \
	-D samurai=disabled \
	-D tracy=disabled \
	-D ui=disabled \
	-D website=disabled \
	build
ninja -C build

DESTDIR=$DESTDIR ./build/muon install

strip --strip-unneeded "$DESTDIR/usr/bin/muon"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Devel-muon@$VERSION.tar.gz"
doas rm -rf $DESTDIR
