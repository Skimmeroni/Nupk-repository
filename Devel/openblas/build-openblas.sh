#!/bin/sh

set -eu

PRETTY_NAME=openblas
MAJOR=0
MINOR=3
PATCH=30
VERSION=0.3.30

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/OpenMathLib/OpenBLAS/releases/download/v$VERSION/OpenBLAS-$VERSION.tar.gz

gzip -cd OpenBLAS-$VERSION.tar.gz | tar -x
cd OpenBLAS-$VERSION

# Let the build system cook
# It will pick all flags by itself (even -march and -mtune)
unset CFLAGS
unset FFLAGS

make PREFIX=/usr
make PREFIX=/usr DESTDIR=$DESTDIR install

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-openblas@$VERSION.tar.gz"
doas rm -rf $DESTDIR
