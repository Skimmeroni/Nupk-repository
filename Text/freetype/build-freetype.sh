#!/bin/sh

set -eu

PRETTY_NAME=freetype
MAJOR=2
MINOR=14
PATCH=1
VERSION=2.14.1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://download-mirror.savannah.gnu.org/releases/freetype/freetype-$VERSION.tar.xz

xz -cd freetype-$VERSION.tar.xz | tar -x
cd freetype-$VERSION

# Harfbuzz depends on Freetype, and Freetype depends on Harfbuzz
# The dummy approach to prevent a circular dependency is to build
# both without the other and then to rebuild them cross-referencing
# each other.

# A better alternative would be to take advantage of the Harfbuzz
# wrap present as a meson subproject, which circumvents this
# interdependency. However, the way in which subproject Harfbuzz
# is built should possibly match the way in which system Harfbuzz
# is built. Moreover, muon is kind of hit and miss.
# This is to be investigated

pkg-config --exists harfbuzz
if [ $? == 0 ]
then
	HARFBUZZ_AT_HOME=enabled
else
	HARFBUZZ_AT_HOME=disabled
fi

muon setup \
	-D prefix=/usr \
	-D default_library=both \
	-D harfbuzz=$HARFBUZZ_AT_HOME \
	-D zlib=enabled \
	-D brotli=disabled \
	-D bzip2=disabled \
	-D png=enabled \
	-D tests=disabled \
	build

ninja -C build
muon -C build install -d $DESTDIR

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-freetype@$VERSION.tar.gz"
doas rm -rf $DESTDIR
