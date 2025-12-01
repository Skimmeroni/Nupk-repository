#!/bin/sh

set -eu

PRETTY_NAME=utf8proc
MAJOR=2
MINOR=11
PATCH=2
VERSION=2.11.2

mkdir temporary-builddir
DESTDIR="$PWD/temporary-builddir"

curl --location --remote-name --skip-existing https://github.com/JuliaStrings/utf8proc/releases/download/v$VERSION/utf8proc-$VERSION.tar.gz

gzip -cd utf8proc-$VERSION.tar.gz | tar -x
cd utf8proc-$VERSION

sed 's|prefix=/usr/local|prefix=/usr|g' Makefile > Makefile.new
mv Makefile.new Makefile

make
make DESTDIR=$DESTDIR install

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-libutf8proc@$VERSION.tar.gz"
doas rm -rf $DESTDIR
