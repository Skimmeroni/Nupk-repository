#!/bin/sh -e

PRETTY_NAME=tesseract-ocr-data
MAJOR=4
MINOR=1
PATCH=0
VERSION=4.1.0

DESTDIR="$PWD/temporary-destdir"
[ -d $DESTDIR ] || mkdir temporary-destdir

curl --location --remote-name --skip-existing https://github.com/tesseract-ocr/tessdata_best/archive/refs/tags/$VERSION.tar.gz

gzip -cd $VERSION.tar.gz | tar -x

# Adjust to one's accord
LANGUAGES="eng ita fra spa rus"

for l in $LANGUAGES
do
	install -Dm644 tessdata_best-$VERSION/$l.traineddata $DESTDIR/usr/share/tessdata/$l.traineddata
done

doas chown -R root:root $DESTDIR
cd $DESTDIR
doas sh -c "tar -cf - * | gzip > tesseract-data@$VERSION.tar.gz"
doas rm -rf $DESTDIR
