#!/bin/sh -e

PRETTY_NAME=oksh
MAJOR=7
MINOR=8
PATCH=
VERSION=7.8

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/ibara/oksh/releases/download/oksh-$VERSION/oksh-$VERSION.tar.gz

gzip -cd oksh-$VERSION.tar.gz | tar -x
cd oksh-$VERSION

./configure \
	--prefix=/usr \
	--bindir=/usr/bin \
	--mandir=/usr/share/man \
	--enable-curses \
	--enable-static \
	--strip

make
make DESTDIR=$DESTDIR install

ln -sf oksh "$DESTDIR/usr/bin/sh"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Base-oksh@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
