#!/bin/sh -e

PRETTY_NAME=bc-gh
MAJOR=7
MINOR=1
PATCH=0
VERSION=7.1.0

# NOTE: Toybox has a bc implementation, which at the moment
# is just a respin of an old version of bc-gh

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/gavinhoward/bc/releases/download/$VERSION/bc-$VERSION.tar.gz

gzip -cd bc-$VERSION.tar.gz | tar -x
cd bc-$VERSION

./configure \
	--prefix=/usr \
	--enable-editline \
	--disable-nls \
	--disable-generated-tests \
	--disable-problematic-tests

make
make DESTDIR=$DESTDIR install

find "$DESTDIR/usr/bin" -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-bc@$VERSION.tar.gz"
doas rm -rf $DESTDIR
