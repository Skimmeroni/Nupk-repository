#!/bin/sh

set -eu

PRETTY_NAME=cargo-c
MAJOR=0
MINOR=10
PATCH=18
VERSION=0.10.18

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://github.com/lu-zero/cargo-c/archive/refs/tags/v$VERSION.tar.gz

gzip -cd v$VERSION.tar.gz | tar -x
cd cargo-c-$VERSION

# Use system libraries
export LIBGIT2_NO_VENDOR=1
export LIBSSH2_SYS_USE_PKG_CONFIG=1
export LIBSQLITE3_SYS_USE_PKG_CONFIG=1

cargo fetch
RUSTFLAGS="$RUSTFLAGS -C strip=symbols" cargo build --frozen --release
install -Dm755 target/release/cargo-capi     "$DESTDIR/usr/bin/cargo-capi"
install -Dm755 target/release/cargo-cbuild   "$DESTDIR/usr/bin/cargo-cbuild"
install -Dm755 target/release/cargo-cinstall "$DESTDIR/usr/bin/cargo-cinstall"
install -Dm755 target/release/cargo-ctest    "$DESTDIR/usr/bin/cargo-ctest"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Devel-cargo-c@$VERSION.tar.gz"
doas rm -rf $DESTDIR
