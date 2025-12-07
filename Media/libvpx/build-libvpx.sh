#!/bin/sh

set -eu

PRETTY_NAME=libvpx
MAJOR=1
MINOR=15
PATCH=2
VERSION=1.15.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/webmproject/libvpx/archive/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd libvpx-$VERSION

# diff --version is a GNU thing
sed 's|diff --version|command -v diff|' configure > configure.new
mv configure.new configure
chmod +x configure

# cat -n is a GNU thing
sed 's|cat -n|cat|' build/make/configure.sh > build/make/configure.sh.new
mv build/make/configure.sh.new build/make/configure.sh
chmod +x build/make/configure.sh

./configure \
	--prefix=/usr \
	--libdir=/usr/lib \
	--enable-shared \
	--enable-static \
	--enable-optimizations \
	--enable-vp8 \
	--enable-vp9 \
	--disable-unit-tests \
	--disable-tools \
	--disable-examples

make
make DESTDIR=$DESTDIR install

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-libvpx@$VERSION.tar.gz"
doas rm -rf $DESTDIR
