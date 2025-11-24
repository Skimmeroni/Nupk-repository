#!/bin/sh -e

PRETTY_NAME=util-linux
MAJOR=2
MINOR=41
PATCH=2
VERSION=2.41.2

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v$MAJOR.$MINOR/util-linux-$VERSION.tar.xz

xz -cd util-linux-$VERSION.tar.xz | tar -x
cd util-linux-$VERSION

./configure \
	--prefix=/usr \
	--libdir=/usr/lib \
	--bindir=/usr/bin \
	--sbindir=/usr/bin \
	--enable-usrdir-path \
	--enable-fs-paths-default=/usr/bin \
	--disable-all-programs \
	--disable-bash-completion \
	--disable-makeinstall-chown \
	--enable-libmount \
	--enable-libblkid \
	--enable-libfdisk \
	--enable-libsmartcols \
	--enable-libuuid \
	--enable-fdisks \
	--enable-fsck \
	--enable-wipefs \
	--enable-mkfs \
	--without-udev \
	--without-readline \
	--without-libmagic \
	--without-cap-ng \
	--without-python

make
make DESTDIR=$DESTDIR install-strip

rm -rf "$DESTDIR/usr/share/man/man3"
find $DESTDIR -type f -name '*.la' -delete

# For some reason, this directory is created anyway
rmdir "$DESTDIR/usr/sbin"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Base-util-linux@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
