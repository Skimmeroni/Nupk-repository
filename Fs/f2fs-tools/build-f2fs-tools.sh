#!/bin/sh

set -eu

PRETTY_NAME=f2fs-tools
MAJOR=1
MINOR=16
PATCH=0
VERSION=1.16.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/f2fs-tools-$VERSION.tar.gz
curl --location --remote-name --skip-existing https://gitweb.gentoo.org/repo/gentoo.git/plain/sys-fs/f2fs-tools/files/f2fs-tools-$VERSION-musl-1.2.4-lfs.patch

gzip -cd f2fs-tools-$VERSION.tar.gz | tar -x
cd f2fs-tools-$VERSION

# Both patches should be unnecessary in the upcoming release
patch -p1 < ../f2fs-tools-$VERSION-musl-1.2.4-lfs.patch
patch -p1 < ../bypass-silly-ifndef.patch

autoreconf -vfi

./configure \
	--prefix=/usr \
	--sbindir=/usr/bin \
	--enable-shared \
	--enable-static \
	--with-blkid \
	--without-lz4 \
	--without-lzo2 \
	--without-selinux

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -name '*.la' -type fl -delete

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Fs-f2fs-tools@$VERSION.tar.gz"
doas rm -rf $DESTDIR
