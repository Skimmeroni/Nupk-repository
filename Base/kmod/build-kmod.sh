#!/bin/sh -e

PRETTY_NAME=kmod
MAJOR=34
MINOR=2
PATCH=
VERSION=34.2

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://kernel.org/pub/linux/utils/kernel/kmod/kmod-$VERSION.tar.xz

xz -cd kmod-$VERSION.tar.xz | tar -x
cd kmod-$VERSION

# Long options are a GNU thing
sed 's|--force --relative|-fr|g' Makefile.am > Makefile.am.new
mv Makefile.am.new Makefile.am
sed 's|--force --relative|-fr|g' Makefile.in > Makefile.in.new
mv Makefile.in.new Makefile.in

# TODO: for the love of God, switch to muon
./configure \
	--prefix=/usr \
	--sbindir=/usr/bin \
	--sysconfdir=/etc \
	--with-noarch-pkgconfigdir=/usr/lib/pkgconfig \
	--without-bashcompletiondir \
	--without-fishcompletiondir \
	--without-zshcompletiondir \
	--without-xz \
	--without-zlib \
	--without-zstd \
	--without-openssl \
	--enable-manpages

make
make DESTDIR=$DESTDIR install-strip

find $DESTDIR -type f -name '*.la' -delete

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../kmod@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
