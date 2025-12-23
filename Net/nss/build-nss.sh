#!/bin/sh

set -eu

PRETTY_NAME=nss
MAJOR=3
MINOR=119
PATCH=1
VERSION=3.119.1

# Taken from Linux from Scratch

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://archive.mozilla.org/pub/security/nss/releases/NSS_${MAJOR}_${MINOR}_${PATCH}_RTM/src/nss-${MAJOR}_${MINOR}_${PATCH}.tar.gz
curl --location --remote-name --skip-existing https://www.linuxfromscratch.org/patches/blfs/svn/nss-standalone-1.patch

gzip -cd nss-${MAJOR}_${MINOR}_${PATCH}.tar.gz | tar -x
cd nss-${MAJOR}_${MINOR}_${PATCH}

# From LFS: patch the Makefile to create a pkgconfig file
patch -p1 < ../nss-standalone-1.patch

# It could be argued that not all machines are 64bit...
make -C nss \
	BUILD_OPT=1 \
	NSPR_INCLUDE_DIR=/usr/include/nspr \
	USE_SYSTEM_ZLIB=1 \
	NSS_ENABLE_WERROR=0 \
	NSS_DISABLE_GTESTS=1 \
	NSS_USE_SYSTEM_SQLITE=1 \
	USE_64=1

# Why is there no install target?

# Note: dist contains symlinks that have to be dereferenced
# the install utility is not standardized, hence there is no
# guarantee that it can dereference. We use cp -L just in case
# Fixing permissions is most likely overkill but can't hurt
mkdir -p "$DESTDIR/usr/bin"
cp -L dist/Linux*/bin/certutil "$DESTDIR/usr/bin"
cp -L dist/Linux*/bin/nss-config "$DESTDIR/usr/bin"
cp -L dist/Linux*/bin/pk12util "$DESTDIR/usr/bin"
find "$DESTDIR/usr/bin" -exec chmod 755 {} \;

mkdir -p "$DESTDIR/usr/include/nss"
cp -L dist/public/nss/* "$DESTDIR/usr/include/nss"
cp -L dist/private/nss/* "$DESTDIR/usr/include/nss"
find "$DESTDIR/usr/include" -exec chmod 644 {} \;

mkdir -p "$DESTDIR/usr/lib"
cp -L dist/Linux*/lib/*.so "$DESTDIR/usr/lib"
cp -L dist/Linux*/lib/*.chk "$DESTDIR/usr/lib"
find "$DESTDIR/usr/lib" -name '*.so' -exec chmod 755 {} \;
find "$DESTDIR/usr/lib" -name '*.chk' -exec chmod 644 {} \;

install -Dm644 dist/Linux*/lib/pkgconfig/nss.pc "$DESTDIR/usr/lib/pkgconfig/nss.pc"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Net-nss@$VERSION.tar.gz"
doas rm -rf $DESTDIR
