#!/bin/sh -e

PRETTY_NAME=jsoncpp
MAJOR=1
MINOR=9
PATCH=6
VERSION=1.9.6

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/open-source-parsers/jsoncpp/archive/$VERSION/jsoncpp-$VERSION.tar.gz

gzip -cd jsoncpp-$VERSION.tar.gz | tar -x
cd jsoncpp-$VERSION

# Muon does not support the cmake module (yet)
patch -p1 < ../bypass-cmake-module.patch

muon setup \
	-D tests=false \
	-D default_library=both \
	-D prefix=/usr \
	build

ninja -C build
muon -C build install -d $DESTDIR

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../System-jsoncpp@$VERSION.tar.gz"
doas rm -rf $DESTDIR
