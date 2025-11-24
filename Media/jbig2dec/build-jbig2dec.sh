#!/bin/sh -e

PRETTY_NAME=jbig2dec
MAJOR=0
MINOR=20
PATCH=
VERSION=0.20

if [ ! -f $0 ]; then return; fi

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
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Media-jbig2dec@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
