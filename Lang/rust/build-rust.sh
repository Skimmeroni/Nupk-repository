#!/bin/sh

set -eu

PRETTY_NAME=rust
MAJOR=1
MINOR=90
PATCH=0
VERSION=1.90.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://static.rust-lang.org/dist/rustc-$VERSION-src.tar.xz
curl --location --remote-name --skip-existing https://gitweb.gentoo.org/proj/rust-patches.git/plain/$VERSION-compiler-musl-dynamic-linking.patch?h=$VERSION

xz -cd rustc-$VERSION-src.tar.xz | tar -x
cd rustc-$VERSION-src

# Static linking is not supported with musl, but it is still enabled by default
# This means that -C crt-static=false has to be specified everytime a program
# is to be compiled
# This patch solves the problem by making crt-static=false implicit
patch -p1 < ../$VERSION-compiler-musl-dynamic-linking.patch

# Instruct curl (and by extension cargo) to use the certificates in /etc/ssl/cert.pem
# Without this patch, cargo won't be able to fetch packages from crates.io, since
# cargo (wisely) refuses to operate without SSL
# See https://codeberg.org/kiss-community/repo/src/branch/master/extra/rust/patches/fix-curl.patch
# Alternative solutions are:
# 1) Supplying the certificate file by hand, feeding the environment variable CARGO_HTTP_CAINFO
# 2) Use a more comprehensive suite of certificates, which introduces more dependencies
for crate in $(find vendor -type d -name "curl-sys-*")
do
	(
	cd $crate
	patch -p1 < ../../../instruct-curl-where-to-find-system-certs.patch
	# To prevent tampering, cargo refuses to compile a crate if the checksum
	# does not match. This includes a crate whose source code has been patched
	# This can be circumvented by manipulating the checksum file
	sed 's/\("files":{\)[^}]*/\1/' .cargo-checksum.json > .cargo-checksum.json.new
	mv .cargo-checksum.json.new .cargo-checksum.json
	)
done

export LIBSSH2_SYS_USE_PKG_CONFIG=1
export LIBSQLITE3_SYS_USE_PKG_CONFIG=1
# Just in case
unset RUSTFLAGS

# Note: only native target is built. This may or may not be what you want
sed "s|@TRIPLET@|$(cc -dumpmachine)|g" ../bootstrap.toml.stub > bootstrap.toml

./x.py build
DESTDIR=$DESTDIR ./x.py install

rm -rf "$DESTDIR/etc"
rm -rf "$DESTDIR/usr/share/doc"
rm -rf "$DESTDIR/usr/share/zsh"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Lang-rust@$VERSION.tar.gz"
doas rm -rf $DESTDIR
