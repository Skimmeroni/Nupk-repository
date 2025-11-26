#!/bin/sh -e

PRETTY_NAME=mupdf
MAJOR=1
MINOR=26
PATCH=11
VERSION=1.26.11

if [ ! -f $0 ]; then return; fi

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://www.mupdf.com/downloads/archive/mupdf-$VERSION-source.tar.gz

gzip -cd mupdf-$VERSION-source.tar.gz | tar -x
cd mupdf-$VERSION-source

# Make sure that vendored libraries are not used
for vendored in brotli curl freeglut freetype gumbo-parser harfbuzz jbig2dec leptonica libjpeg openjpeg tesseract zint zlib zxing-cpp
do
	rm -rf thirdparty/$vendored
done

cat > user.make << EOF
HAVE_GLUT=no
HAVE_LIBCRYPTO=no
HAVE_X11=no
HAVE_ZXINGCPP=no
HAVE_SYS_ZXINGCPP=no
USE_SYSTEM_LIBS=yes
USE_SYSTEM_BROTLI=yes
USE_SYSTEM_GLUT=no
USE_SYSTEM_MUJS=no
USE_SYS_ZXINGCPP=no
EOF

make prefix=/usr shared=yes build=release XCFLAGS="-fPIC"
make prefix=/usr shared=yes build=release DESTDIR=$DESTDIR install

rm -rf "$DESTDIR/usr/share/doc"

doas chown -R root:root $DESTDIR
doas sh -c "tar -zcC $DESTDIR . | gzip > ../Text-mupdf@$VERSION.tar.gz"
CALLER_UID=$(id -un)
CALLER_GID=$(id -gn)
doas chown -R $CALLER_UID:$CALLER_GID $DESTDIR
