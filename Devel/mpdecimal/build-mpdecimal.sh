#!/bin/sh -e

PRETTY_NAME=mpdecimal
MAJOR=4
MINOR=0
PATCH=1
VERSION=4.0.1

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name www.bytereef.org/software/mpdecimal/releases/mpdecimal-$VERSION.tar.gz

gzip -cd mpdecimal-$VERSION.tar.gz | tar -x
cd mpdecimal-$VERSION

./configure \
	--prefix=/usr \
	--enable-cxx \
	--enable-static \
	--enable-shared \
	--enable-pc \
	--disable-doc

make
make DESTDIR=$DESTDIR install

find $DESTDIR -name '*.a'   -type f -exec strip --strip-unneeded {} \;
find $DESTDIR -name '*.so*' -type f -exec strip --strip-unneeded {} \;

install -Dm644 COPYRIGHT.txt "$DESTDIR/usr/share/LICENSES/mpdecimal.license"
rm -rf $DESTDIR/usr/share/doc

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Devel-mpdecimal@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
