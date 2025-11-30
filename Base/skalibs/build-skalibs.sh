#!/bin/sh -e

PRETTY_NAME=skalibs
MAJOR=2
MINOR=14
PATCH=4
VERSION=2.14.4.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://www.skarnet.org/software/skalibs/skalibs-$VERSION.tar.gz

gzip -cd skalibs-$VERSION.tar.gz | tar -x
cd skalibs-$VERSION

./configure \
	--prefix=/usr \
	--with-sysdep-devurandom=yes

make
make DESTDIR=$DESTDIR install

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Base-skalibs@$VERSION.tar.gz"
doas rm -rf $DESTDIR
