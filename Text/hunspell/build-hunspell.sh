#!/bin/sh

set -eu

PRETTY_NAME=hunspell
MAJOR=1
MINOR=7
PATCH=2
VERSION=1.7.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/hunspell/hunspell/releases/download/v$VERSION/hunspell-$VERSION.tar.gz

gzip -cd hunspell-$VERSION.tar.gz | tar -x
cd hunspell-$VERSION

autoreconf -vf

./configure \
	--prefix=/usr \
	--with-ui \
	--without-readline \
	--disable-nls

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/man/hu"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Text-hunspell@$VERSION.tar.gz"
doas rm -rf $DESTDIR
