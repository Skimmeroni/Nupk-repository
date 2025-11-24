#!/bin/sh -e

PRETTY_NAME=musl
MAJOR=1
MINOR=2
PATCH=5
VERSION=1.2.5

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://codeberg.org/kiss-community/repo/raw/branch/master/core/musl/files/tree.h
curl --location --remote-name --skip-existing https://codeberg.org/kiss-community/repo/raw/branch/master/core/musl/files/queue.h
curl --location --remote-name --skip-existing https://codeberg.org/kiss-community/repo/raw/branch/master/core/musl/files/cdefs.h
curl --location --remote-name --skip-existing https://codeberg.org/kiss-community/repo/raw/branch/master/core/musl/files/getent.c
curl --location --remote-name --skip-existing https://codeberg.org/kiss-community/repo/raw/branch/master/core/musl/files/getconf.c
curl --location --remote-name --skip-existing https://www.musl-libc.org/releases/musl-$VERSION.tar.gz

mkdir -p "$DESTDIR/usr/bin"
$CC $CFLAGS -static getent.c   -o "$DESTDIR/usr/bin/getent"
$CC $CFLAGS -static getconf.c  -o "$DESTDIR/usr/bin/getconf"

install -Dm755 cdefs.h "$DESTDIR/usr/include/sys/cdefs.h"
install -Dm755 queue.h "$DESTDIR/usr/include/sys/queue.h"
install -Dm755 tree.h  "$DESTDIR/usr/include/sys/tree.h"

gzip -cd musl-$VERSION.tar.gz | tar -x
cd musl-$VERSION

./configure \
	--prefix=/usr \
	--syslibdir=/usr/lib

make
make DESTDIR=$DESTDIR install

# This *should* make musl architecture-independent
# Taken from Alpine Linux
case $(uname -m) in
	aarch64*)	ARCH="aarch64" ;;
	arm*)		ARCH="arm" ;;
	x86)		ARCH="i386" ;;
	x86_64)		ARCH="x86_64" ;;
	ppc)		ARCH="powerpc" ;;
	ppc64*)		ARCH="powerpc64" ;;
	s390*)		ARCH="s390x" ;;
	mips64*)	ARCH="mips64" ;;
	mips*)		ARCH="mips" ;;
	riscv64)	ARCH="riscv64" ;;
	loongarch64)	ARCH="loongarch64" ;;
esac

ln -sf libc.so "$DESTDIR/usr/lib/ld-musl-$ARCH.so.1"

strip --strip-unneeded "$DESTDIR/usr/bin/getent"
strip --strip-unneeded "$DESTDIR/usr/bin/getconf"

cat > "$DESTDIR/usr/bin/ldd" << EOF
#!/bin/sh
exec /lib/ld-musl-$ARCH.so.1 --list "\$@"
EOF

chmod 755 "$DESTDIR/usr/bin/ldd"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Base-musl@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
