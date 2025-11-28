#!/bin/sh -e

PRETTY_NAME=fribidi
MAJOR=1
MINOR=0
PATCH=16
VERSION=1.0.16

mkdir temporary-builddir
DESTDIR="$PWD/temporary-builddir"

curl --location --remote-name --skip-existing https://github.com/fribidi/fribidi/releases/download/v$VERSION/fribidi-$VERSION.tar.xz

xz -cd fribidi-$VERSION.tar.xz | tar -x
cd fribidi-$VERSION

muon setup \
	-D prefix=/usr \
	-D default_library=both \
	-D bin=false \
	-D docs=false \
	-D tests=false \
	build

ninja -C build
muon -C build install -d $DESTDIR

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Text-fribidi@$VERSION.tar.gz"
doas rm -rf $DESTDIR
