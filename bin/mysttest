#!/bin/bash -
# ------------------------------------------
# coldtest.sh
#
# Summary
# A quick test script that "stresses" the
# administration interface.
#
# @author
# 	Antonio R. Collins II (rc@tubularmodular.com, ramar.collins@gmail.com)
# 
# @copyright
# 	Copyright 2016-Present, "Tubular Modular"
# 	Original Author Date: Tue Jul 26 07:26:29 2016 -0400
#
# Usage
# ./coldmvc-test.sh 
# No options are necessary...
#
# Body
# This test script makes sure that instances
# are being created as they should.
#
# Todo
# - Does xargs check for failure?
# ------------------------------------------

# Variables 
# DIR can be set on the command line, for places that Lucee is installed
DIR=${1:-tmp}
STATUS=1


# Catch empty directories
[ -z "$DIR" ] && { 
	printf "$0: No directory specified.\n" > /dev/stderr
	exit 0
}


# If the directory is not a directory, and it's not tmp, stop
[ ! -z $DIR ] && { 
	[ ! -d "$DIR" ] && {
	echo $DIR
		[ ${DIR:0:1} == 't' ] && [ ${DIR:1:1} == 'm' ] && [ ${DIR:2:1} == 'p' ] && mkdir tmp || {
			printf "$0: Directory specified does not exist.\n" > /dev/stderr
			exit 0
		}
	}
}


# Try running whatever 
[ 1 -eq 0 ] && {
	# Short options
	./coldmvc.sh -v -c -n "MyNewInstance1" -f $DIR/MyNewInstance1 
	./coldmvc.sh -v -c -n "MyNewInstance2" -f $DIR/MyNewInstance2 -d "A really long description." 
	./coldmvc.sh -v -c -n "MyNewInstance3" -f $DIR/MyNewInstance3 -d "An even longer description." -d "mynewinstance.org" -s "MNIDatasource"

	# Long options
	#./coldmvc.sh --verbose  
}


# 
for n in 0
do
	# Check that dirs exist
	CHECKDIRS=$(cat <<DIR
app
assets
assets/css
assets/js
assets/sass
assets/less
components
db
db/static
files
middleware
routes
log
std
views
DIR
	)

	# Check that it all worked
	printf "$CHECKDIRS" | {
		while read dr
		do 
			f=$DIR/$dr
			test -f $f || { 
				printf "Dir '$f' does not exist.\n" > /dev/stderr
				STATUS=0
				exit 0
			}

		done 
	}

	echo status $STATUS
	[ $STATUS -eq 0 ] && exit

	# Check that files exist
	CHECKFILES=$(cat <<FILES
data.json
Application.cfc
index.cfm
coldmvc.cfc
app/default.cfm
app/Application.cfc
assets/css/4xx-view.css
assets/css/5xx-view.css
components/Application.cfc
db/Application.cfc
middleware/Application.cfc
routes/Application.cfc
setup/Application.cfc
sql/Application.cfc
std/Application.cfc
std/4xx-view.cfm
std/failure.cfm
std/5xx-view.cfm
std/admin-view.cfm
std/html-view.cfm
std/mime-view.cfm
views/Application.cfc
views/default.cfm
FILES
	)

	# Check that it all worked
	printf "$CHECKFILES" | {
		while read file 
		do 
			f=$DIR/$file
			test -f $f || { 
				printf "File '$f' does not exist.\n" > /dev/stderr
				exit 0
			}
		done 
	}
done
