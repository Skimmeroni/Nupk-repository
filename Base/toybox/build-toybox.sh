#!/bin/sh

PRETTY_NAME=toybox
MAJOR=0
MINOR=8
PATCH=12
VERSION=0.8.12

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://landley.net/toybox/downloads/toybox-$VERSION.tar.gz

gzip -cd toybox-$VERSION.tar.gz | tar -x
cd toybox-$VERSION

# TODO: avoid using sed -i
sed -i 's|egrep|grep -E|g' scripts/*.sh

mv ../configuration .config
make oldconfig
make CFLAGS="$CFLAGS -static" LDFLAGS="$LDFLAGS -static" change

# Hopefully unneeded
rm change/*.bad

for i in $(ls -1 change)
do
	install -Dm755 change/$i "$DESTDIR/usr/bin/$i"
done

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Base-toybox@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
