#!/bin/sh -e

### MARKED FOR REMOVAL ###

PRETTY_NAME=jbig2dec
MAJOR=0
MINOR=20
PATCH=
VERSION=0.20

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/ArtifexSoftware/jbig2dec/archive/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd jbig2dec-$VERSION

sh autogen.sh

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static \
	--with-libpng

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Media-jbig2dec@$VERSION.tar.gz"
doas rm -rf $DESTDIR
