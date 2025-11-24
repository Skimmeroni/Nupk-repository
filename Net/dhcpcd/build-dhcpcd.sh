#!/bin/sh -e

PRETTY_NAME=dhcpcd
MAJOR=10
MINOR=3
PATCH=0
VERSION=10.3.0

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/NetworkConfiguration/dhcpcd/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd dhcpcd-$VERSION

# TODO: enable priviledge separation
./configure \
	--dbdir=/var/lib/dhcpcd \
	--prefix=/usr \
	--sbindir=/usr/bin \
	--sysconfdir=/etc \
	--rundir=/run \
	--libexecdir=/usr/lib/dhcpcd \
	--disable-privsep \
	--without-udev \
	--without-openssl

make
make DESTDIR=$DESTDIR BINMODE=755 install

install -Dm755 ../dhcpcd.run "$DESTDIR/etc/sv/dhcpcd/run"
ln -sf /run/runit/supervise.dhcpcd "$DESTDIR/etc/sv/dhcpcd/supervise"

strip --strip-unneeded "$DESTDIR/usr/bin/dhcpcd"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Net-dhcpcd@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
