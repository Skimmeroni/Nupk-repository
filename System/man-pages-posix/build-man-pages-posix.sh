#!/bin/sh -e

PRETTY_NAME=man-pages-posix
MAJOR=2017
MINOR=a
PATCH=
VERSION=2017a

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://mirrors.edge.kernel.org/pub/linux/docs/man-pages/man-pages-posix/man-pages-posix-$MAJOR-$MINOR.tar.xz

xz -cd man-pages-posix-$VERSION.tar.xz | tar -x
cd man-pages-posix-$MAJOR

mkdir -p $DESTDIR/usr/share/man

for j in 0 1 3
do
	mv man${j}p $DESTDIR/usr/share/man/man$j
	# The '.p' suffix is no mistake: it stands for 'POSIX'.
	# Frankly, I have no use for this distinction
	for i in $DESTDIR/usr/share/man/man${j}/*.${j}p
	do
		mv $i ${i%.${j}p}.$j	
	done
done

# Useful trick: remove manpages of stuff you don't have
for i in $DESTDIR/usr/share/man/man1/*.1
do
	if [ ! "$(command -v $(basename ${i%.1}))" ]
	then
		rm $i
	fi
done

# Already present in gcc/binutils
rm $DESTDIR/usr/share/man/man1/ar.1
rm $DESTDIR/usr/share/man/man1/nm.1
rm $DESTDIR/usr/share/man/man1/strings.1
rm $DESTDIR/usr/share/man/man1/strip.1
# Already present in bc
rm $DESTDIR/usr/share/man/man1/bc.1
# Already present in file
rm $DESTDIR/usr/share/man/man1/file.1
# Already present in m4
rm $DESTDIR/usr/share/man/man1/m4.1
# Already present in mandoc
rm $DESTDIR/usr/share/man/man1/man.1
# Already present in ncurses
rm $DESTDIR/usr/share/man/man1/tabs.1
rm $DESTDIR/usr/share/man/man1/tput.1

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../System-man-pages-posix@$VERSION.tar.gz"
doas rm -rf $DESTDIR
