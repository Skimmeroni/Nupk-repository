#!/bin/sh -e

PRETTY_NAME=openssh
MAJOR=10
MINOR=2
PATCH=p1
VERSION=10.2p1

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-$VERSION.tar.gz

gzip -cd openssh-$VERSION.tar.gz | tar -x
cd openssh-$VERSION

./configure \
	--prefix=/usr \
	--datadir=/usr/share/openssh \
	--sysconfdir=/etc/ssh \
	--sbindir=/usr/bin \
	--libexecdir=/usr/lib/openssh \
	--without-selinux \
	--with-privsep-user=nobody \
	--with-mantype=doc \
	--without-rpath \
	--enable-strip \
	--with-ssl-engine \
	--with-pid-dir=/run \
	--disable-wtmp \
	--disable-utmp \
	--disable-security-key

make
make DESTDIR=$DESTDIR install

install -Dm755 ../sshd.run "$DESTDIR/etc/sv/sshd/run" 
ln -sf /run/runit/supervise.sshd "$DESTDIR/etc/sv/sshd/supervise"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Net-openssh@$VERSION.tar.gz"
doas rm -rf $DESTDIR
