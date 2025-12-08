#!/bin/sh

set -eu

PRETTY_NAME=tre
MAJOR=
MINOR=
PATCH=
VERSION=0.9.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/laurikari/tre/releases/download/v$VERSION/tre-$VERSION.tar.gz

gzip -cd tre-$VERSION.tar.gz | tar -x
cd tre-$VERSION

# No gettext
sed 's|autopoint||' utils/autogen.sh > utils/autogen.sh.new
mv utils/autogen.sh.new utils/autogen.sh
chmod +x utils/autogen.sh

sh utils/autogen.sh

./configure \
	--prefix=/usr \
	--enable-shared \
	--enable-static \
	--enable-multibyte \
	--enable-wchar \
	--enable-approx \
	--disable-debug \
	--disable-nls \
	--disable-agrep

make
make DESTDIR=$DESTDIR install-strip

rm "$DESTDIR/usr/lib/libtre.la"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-tre@$VERSION.tar.gz"
doas rm -rf $DESTDIR
