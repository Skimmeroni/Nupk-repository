#!/bin/sh -e

PRETTY_NAME=rhash
MAJOR=1
MINOR=4
PATCH=6
VERSION=1.4.6

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/rhash/RHash/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd RHash-$VERSION

./configure \
	--prefix=/usr \
	--sysconfdir=/etc \
	--enable-lib-static \
	--enable-lib-shared \
	--enable-openssl \
	--disable-gettext \
	--extra-cflags=$CFLAGS \
	--extra-ldflags=$LDFLAGS

make
make DESTDIR=$DESTDIR install install-pkg-config
make -C librhash DESTDIR=$DESTDIR install-lib-headers install-so-link

install -Dm644 COPYING "$DESTDIR/usr/share/LICENSES/rhash.license"

find $DESTDIR/usr/bin       -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-rhash@$VERSION.tar.gz"
doas rm -rf $DESTDIR
