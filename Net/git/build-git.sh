#!/bin/sh -e

PRETTY_NAME=git
MAJOR=2
MINOR=51
PATCH=2
VERSION=2.51.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://mirrors.edge.kernel.org/pub/software/scm/git/git-manpages-$VERSION.tar.xz
curl --location --remote-name --skip-existing https://mirrors.edge.kernel.org/pub/software/scm/git/git-$VERSION.tar.xz

xz -cd git-$VERSION.tar.xz | tar -x
cd git-$VERSION

export LDFLAGS="$LDFLAGS -static"

cat > config.mak << EOF
NO_GETTEXT=YesPlease
NO_SVN_TESTS=YesPlease
NO_TCLTK=YesPlease
NO_EXPAT=YesPlease
NO_NSEC=YesPlease
NO_PYTHON=YesPlease
NO_PERL=YesPlease
NO_SYS_POLL_H=1
NO_CROSS_DIRECTORY_HARDLINKS=1
NO_INSTALL_HARDLINKS=1
NO_OPENSSL=YesPlease
EOF

./configure \
	--prefix=/usr \
	--libexecdir=/usr/lib \
	ac_cv_lib_curl_curl_global_init=yes \
	ac_cv_snprintf_returns_bogus=no \
	ac_cv_fread_reads_directories=yes

make LIBS="$(curl-config --static-libs) libgit.a reftable/libreftable.a xdiff/lib.a -lz"
make DESTDIR=$DESTDIR install

mkdir -p "$DESTDIR/usr/share/man"
xz -cd ../git-manpages-$VERSION.tar.xz | tar -x -C "$DESTDIR/usr/share/man"

rm -rf "$DESTDIR/usr/share/bash-completion"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Net-git@$VERSION.tar.gz"
doas rm -rf $DESTDIR
