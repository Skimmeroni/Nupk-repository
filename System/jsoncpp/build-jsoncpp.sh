#!/bin/sh

set -eu

PRETTY_NAME=jsoncpp
MAJOR=1
MINOR=9
PATCH=6
VERSION=1.9.6

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/open-source-parsers/jsoncpp/archive/$VERSION/jsoncpp-$VERSION.tar.gz

gzip -cd jsoncpp-$VERSION.tar.gz | tar -x
cd jsoncpp-$VERSION

meson setup \
	-D prefix=/usr \
	-D buildtype=release \
	-D default_library=both \
	-D strip=true \
	-D tests=false \
	build

meson compile -C build --verbose
meson install -C build --destdir $DESTDIR

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-jsoncpp@$VERSION.tar.gz"
doas rm -rf $DESTDIR
