#!/bin/sh -e

PRETTY_NAME=skalibs
MAJOR=2
MINOR=14
PATCH=4
VERSION=2.14.4.0

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

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
doas sh -c "tar -zcC $DESTDIR . | gzip > ../skalibs@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
