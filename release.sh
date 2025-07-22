#!/bin/sh

TAR="tar jcf"
EXT="bz2"

DIR=`dirname "$0"`

#-----------------------------------------------------------
# get Version
#-----------------------------------------------------------
VERSION=`head -20 lib/SatsukiApp/adiary.pm | grep "\\$OUTVERSION" | sed "s/[^=]*=[^\"']*\([\"']\)\([^\"']*\)\1.*/\2/"`

if [ "$VERSION" = "" -o "`echo $VERSION | grep ' '`" ]
then
	echo "Version detection failed: $VERSION"
	exit
fi

#-----------------------------------------------------------
# set variables
#-----------------------------------------------------------
RELEASE=adiary-$VERSION

BASE="
	adiary.cgi
	adiary.fcgi
	adiary.httpd.pl
	adiary.env.cgi.sample
	adiary.conf.cgi.sample
	README.md
	CHANGES.txt
	index.html
	.htaccess.sample
"
EXE="
	adiary.exe
	adiary_service.exe
"
#-----------------------------------------------------------
# make release directory
#-----------------------------------------------------------
if [ ! -e $RELEASE ]
then
	mkdir $RELEASE
fi

#-----------------------------------------------------------
# copy files to release directory
#-----------------------------------------------------------
cp -Rp $CPFLAGS skel pub-dist info js lib theme $RELEASE/

cp -Rp $CPFLAGS $BASE $RELEASE/

cp -Rp $CPFLAGS plugin $RELEASE/
rm -rf $RELEASE/plugin/\@*
rm -rf $RELEASE/lib/Satsuki/.git

cp -p $DIR/files/* $RELEASE/

#-----------------------------------------------------------
# make other directory
#-----------------------------------------------------------
# __cache
mkdir -p $RELEASE/__cache
cp -p $CPFLAGS __cache/.htaccess  $RELEASE/__cache/
cp -p $CPFLAGS __cache/index.html $RELEASE/__cache/

# data
mkdir -p $RELEASE/data
cp -p $CPFLAGS data/.htaccess  $RELEASE/data/
cp -p $CPFLAGS data/index.html $RELEASE/data/

# pub
mkdir -p $RELEASE/pub
cp -p $CPFLAGS pub/.gitkeep $RELEASE/pub/

# skel.local
mkdir -p $RELEASE/skel.local
cp -p $CPFLAGS skel.local/.htaccess  $RELEASE/skel.local/
cp -p $CPFLAGS skel.local/README.txt $RELEASE/skel.local/

#-----------------------------------------------------------
# RELEASE files check
#-----------------------------------------------------------
# if not exist RELEASE dir, exit
if [ ! -e $RELEASE/ ]
then
	echo $RELEASE/ not exists.
	exit
fi

if [ "$1" = "test" -o  "$2" = "test" ]
then
	echo
	echo No packaging for check
	exit
fi


echo "\n---Packaging--------------------------------------------------------------------"

#-----------------------------------------------------------
# Windows zip
#-----------------------------------------------------------
if [ `which zip` ]; then
	echo zip -q $RELEASE-win_x64.zip -r $RELEASE/
	     zip -q $RELEASE-win_x64.zip -r $RELEASE/
fi
rm -f $RELEASE/*.exe

#-----------------------------------------------------------
# Release file
#-----------------------------------------------------------
echo $TAR $RELEASE.tar.$EXT $RELEASE/
     $TAR $RELEASE.tar.$EXT $RELEASE/

rm -rf $RELEASE
