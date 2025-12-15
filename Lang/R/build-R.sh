#!/bin/sh

set -eu

PRETTY_NAME=r
MAJOR=4
MINOR=5
PATCH=2
VERSION=4.5.2

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir -p $DESTDIR

curl --location --remote-name --skip-existing https://cran.r-project.org/src/base/R-$MAJOR/R-$VERSION.tar.gz

gzip -cd R-$VERSION.tar.gz | tar -x
cd R-$VERSION

# TODO: lto?
./configure \
	ac_cv_path_PDFTEX= \
	ac_cv_path_PDFLATEX= \
	ac_cv_path_MAKEINDEX= \
	ac_cv_path_KPSEWHICH= \
	--prefix=/usr \
	--enable-byte-compiled-packages \
	--enable-R-shlib \
	--disable-R-static-lib \
	--disable-R-framework \
	--with-blas=openblas \
	--with-lapack=openblas \
	--with-system-tre \
	--with-cairo \
	--with-ICU \
	--with-jpeglib \
	--with-libpng \
	--with-libtiff \
	--without-R-lto \
	--without-recommended-packages \
	--without-libdeflate-compression \
	--without-nls \
	--without-readline \
	--without-tcltk \
	--without-x

make
make -C src/nmath/standalone

make DESTDIR=$DESTDIR install-strip
make -C src/nmath/standalone DESTDIR=$DESTDIR install

# install-strip seems shaky
strip --strip-unneeded "$DESTDIR/usr/lib/libRmath.so"
strip --strip-unneeded "$DESTDIR/usr/lib/libRmath.a"

mkdir -p "$DESTDIR/usr/share/LICENSES"
mv "$DESTDIR/usr/lib/R/doc/COPYING" "$DESTDIR/usr/share/LICENSES/R.license"
rm -rf "$DESTDIR/usr/lib/R/doc"
# Instead of obliterating the entire folder, it would be better
# to spare translations for the current language (fetching LANG
# or whatever)
rm -rf "$DESTDIR/usr/lib/R/library/translations"

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > ../Lang-R@$VERSION.tar.gz"
doas rm -rf $DESTDIR
