#!/bin/sh -e

PRETTY_NAME=perl
MAJOR=5
MINOR=42
PATCH=0
VERSION=5.42.0

if [ ! -f $0 ]; then return; fi

mkdir temporary-destdir
DESTDIR="$PWD/temporary-destdir"

curl --location --remote-name --skip-existing https://www.cpan.org/src/$MAJOR.0/perl-$VERSION.tar.gz

tar -xf perl-$VERSION.tar.gz
cd perl-$VERSION

export LDFLAGS="$LDFLAGS -pthread"
export CFLAGS="$CFLAGS -DNO_POSIX_2008_LOCALE -D_GNU_SOURCE"

./Configure \
    -des \
    -Dprefix=/usr \
    -Dvendorprefix=/usr \
    -Dusevendorprefix \
    -Duseshrplib \
    -Dusesoname \
    -Dusethreads \
    -Dinc_version_list=none \
    -Dd_sockaddr_in6=define \
    -Dcccdlflags=-fPIC \
    -Dccflags="$CFLAGS" \
    -Dlddlflags="-shared $LDFLAGS" \
    -Dldflags="$LDFLAGS" \
    -Doptimize="-Wall $CFLAGS" \
    -Dcc="$CC" \
    -Dar="$AR" \
    -Dnm="$NM" \
    -Dranlib="$RANLIB" \
    -Dman1dir=/usr/share/man/man1 \
    -Dman3dir=/usr/share/man/man3 \
    -Dinstallman1dir=/usr/share/man/man1 \
    -Dinstallman3dir=/usr/share/man/man3 \
    -Dman1ext=1 \
    -Dman3ext=3pm \
    -Dperl_static_inline="static __inline__" \
    -Dd_static_inline

make
make DESTDIR=$DESTDIR install

# Remove all unneeded files.
find "$DESTDIR" -name \*.pod       -exec rm -f {} +
find "$DESTDIR" -name .packlist    -exec rm -f {} +
find "$DESTDIR" -name README\*     -exec rm -f {} +
find "$DESTDIR" -name TODO\*       -exec rm -f {} +
find "$DESTDIR" -name Change\*     -exec rm -f {} +
find "$DESTDIR" -name \*.bs        -exec rm -f {} +
find "$DESTDIR" -name \*.0 -type f -exec rm -f {} +
rm -rf "$DESTDIR/usr/share/man/man3"

# Fix permissions.
find "$DESTDIR/usr/lib" -type f -exec chmod 644 {} \;

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../perl@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
