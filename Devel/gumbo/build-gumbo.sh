#!/bin/sh -e

### MARKED FOR REMOVAL ###

PRETTY_NAME=gumbo-parser
MAJOR=0
MINOR=13
PATCH=2
VERSION=0.13.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://codeberg.org/grisha/gumbo-parser/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd gumbo-parser

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
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-gumbo@$VERSION.tar.gz"
doas rm -rf $DESTDIR
