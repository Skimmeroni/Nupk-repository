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

# NOTE: the building script is strictly dependent on Bash, rewriting everything
# to make it POSIX-compliant is tantamount to insanity
# One way out could be substituting the current shell (oksh) with a shell
# powerful enough to handle bashisms but still reasonably sized (e.g. yash)
# and see if sed'ing bash away is sufficient

# NOTE: the building script uses egrep, which is deprecated in GNU grep. If you
# happen to be using GNU grep, run "sed 's|egrep|grep -E |g'" on all scripts in
# the scripts folder

# NOTE: Toybox contains many applets, which should be preferred to full-blown
# counterparts. The only exceptions are those utilities that come with an
# actually useful library, such as libarchive or util-linux
mv ../configuration .config
make oldconfig

# Being a fundamental building block, statically linking toybox is reasonable
# TODO: handling SUID is all over the place. This means that, for example,
# su does not work
make CFLAGS="$CFLAGS -static" LDFLAGS="$LDFLAGS -static" change

# If the script fails in building an applet, the process does not stop.
# Instead, the malformed applet is spat out with a .bad suffix and the
# process moves on. If this were to happen, it is best to bail out and
# see what's going on
# TODO: isn't there an exit-on-failure?
if [ ! -z $(find ./change -name '*.bad') ]
then
	printf "An applet failed to build!\n"
	exit 1
fi

for i in change/*
do
	install -Dm755 $i "$DESTDIR/usr/bin/$(basename $i)"
	strip --strip-unneeded "$DESTDIR/usr/bin/$(basename $i)"
done

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Base-toybox@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
