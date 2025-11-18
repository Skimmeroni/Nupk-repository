#!/bin/sh -e

PRETTY_NAME=tzdata
MAJOR=2025
MINOR=b
PATCH=
VERSION=2025b

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://github.com/eggert/tz/archive/refs/tags/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x
cd tz-$VERSION

sed 's|sbin|bin|g' Makefile > Makefile.new
mv Makefile.new Makefile

make
make DESTDIR=$DESTDIR install

rm -rf "$DESTDIR/etc"
rm -rf "$DESTDIR/usr/share/man/man3"

for t in africa asia australasia europe northamerica southamerica
do
	./zic -d "$DESTDIR/usr/share/zoneinfo" $t
	./zic -d "$DESTDIR/usr/share/zoneinfo/right" -L leapseconds $t
done

# POSIX compliance (?)
./zic -d "$DESTDIR/usr/share/zoneinfo" -p America/New_York

strip --strip-unneeded "$DESTDIR/usr/bin/zic"
strip --strip-unneeded "$DESTDIR/usr/bin/zdump"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../tzdata@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
