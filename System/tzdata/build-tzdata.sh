#!/bin/sh

set -eu

PRETTY_NAME=tzdata
MAJOR=2025
MINOR=b
PATCH=
VERSION=2025b

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

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
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../System-tzdata@$VERSION.tar.gz"
doas rm -rf $DESTDIR

printf "\033[1mDon't forget to set up your current timezone!\033[0m\n"
# "ln -sf /usr/share/zoneinfo/[Region]/[Country] /etc/localtime\n"
