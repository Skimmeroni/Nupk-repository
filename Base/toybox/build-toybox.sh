#!/bin/sh

PRETTY_NAME=toybox
MAJOR=0
MINOR=8
PATCH=13
VERSION=0.8.13

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://landley.net/toybox/downloads/toybox-$VERSION.tar.gz

gzip -cd toybox-$VERSION.tar.gz | tar -x
cd toybox-$VERSION

# NOTE: the building scripts are strictly dependent on Bash, rewriting everything
# to make it POSIX-compliant is tantamount to insanity
# One way out could be substituting the current shell (oksh) with a shell
# powerful enough to handle bashisms but still reasonably sized (e.g. yash)
# and see if sed'ing bash away is sufficient
# NOTE: Toybox contains many applets, which should be preferred to full-blown
# counterparts. The only exceptions are those utilities that come with an
# actually useful library, such as libarchive or util-linux

# The scripts use egrep, which is deprecated and prone to fail. grep -E is equivalent
for i in scripts/*.sh
do
	sed 's|egrep|grep -E |g' $i > $i.new
	mv $i.new $i
	chmod +x $i
done

mv ../configuration .config
make oldconfig

# TODO: handling SUID is all over the place. This means that, for example,
# su does not work
make CFLAGS="$CFLAGS -static" LDFLAGS="$LDFLAGS -static" change

# If the script fails in building an applet, the process does not stop.
# Instead, the malformed applet is spat out with a .bad suffix and the
# process moves on.
for i in change/*.bad
do
	applet=$(echo $i | awk '{sub(/.*\//, ""); sub(/\.bad.*/, ""); print}')
	printf "\033[33;1mWARNING!\033[0m \033[1m'%s' failed to build. You might want to check out why\033[0m\n" $applet
	rm $i
done

for i in change/*
do
	install -Dm755 $i "$DESTDIR/usr/bin/${i#change/}"
done

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Base-toybox@$VERSION.tar.gz"
doas rm -rf $DESTDIR
