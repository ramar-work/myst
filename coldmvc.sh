#!/bin/bash -
# -------------------------------------------- #
# coldmvc.sh
#
# @author
#		Antonio R. Collins II (ramar.collins@gmail.com)
# @end
#
# @copyright
# 	Copyright 2016-Present, "Deep909, LLC"
# 	Original Author Date: Tue Jul 26 07:26:29 2016 -0400
# @end
# 
# @summary
# 	An administration interface for ColdMVC sites.
# @end
#
# @usage
# 	
# @end
#
# @body
#  
# @end
# 
# @todo
#		- Be able to build from JSON
# 	- Handle setup tasks and tooling ( like database connections and maintenance ) 
# 	- Convert to Java or C++
# @end
# -------------------------------------------- #

# Variable list
PROGRAM_NAME=coldmvc
DIR=
#SRC= This will be filled out during the install process...
SRC=.
CREATE=0
NO_GIT=0
VERBOSE=0

ERR_NODIR=1
ERR_NONAME=2


# An error function
err() 
{
	STATUS=${2:-0}
	printf "$PROGRAM_NAME: $1\n" > /dev/stderr
	exit $STATUS
}


# A usage function
usage()
{
	STATUS=${2:-0}

	cat <<USAGES
$0:
-c, --create            Create a new instance. 
    --apachify          Create an Apache-style virtual host and an .htaccess file.
    --no-git            Don't create a Git repo.
-e, --engine <arg>      Specify which CFML engine you're running [ Lucee, Coldfusion ]
-f, --folder <arg>      Specify which folder to use when creating a new instance.
-n, --name <arg>        Specify a name to use for a new instance. 
-m, --domain <arg>      Specify a domain name to host this particular instance.
-d, --description <arg> Specify a description for the new instance.
-s, --datasource <arg>  Specify a default datasource for use with the new instance.
-v, --verbose           Be verbose.
-h, --help              Show this help and quit.
USAGES

	exit $STATUS
}


# Catch blank arguments
[ $# -eq 0 ] && usage 0 


# Process any options
while [ $# -gt 0 ]
do
	case "$1" in
		# Administration stuff
		-c|--create)
			CREATE=1
		;;

		--apachify)
			# Create an Apache style virtual host and an .htaccess file
			APACHIFY=1
		;;

		--no-git)
			# Don't create a git repo
			NO_GIT=1
		;;

		# Parameters 
		-f|--folder)
			# Create this directory
			shift
			DIR="$1"
		;;

		-e|--engine)
			# Specify which engine so the right virtual host file will be generated
			shift
			ENGINE="$1"	
		;;

		-n|--name)
			# Another parameter in data.json
			shift
			NAME="$1"	
		;;

		-m|--domain)
			# This isn't truly necessary, but it can be used in data.json 
			shift
			DOMAIN="$1"	
		;;

		-d|--description)
			# Goes in the README
			shift
			DESCRIPTION="$1"	
		;;

		-s|--datasource)
			# Specify a datasource
			shift
			DATASOURCE="$1"	
		;;

		-v|--verbose)	
			# Verbose
			VERBOSE=1
		;;

		--help)	
			usage 0
		;;

		--)	break
		;;

		-*)	printf "$PROGRAM_NAME: Unknown argument received: $1\n" > /dev/stderr; usage 1
		;;
	esac
	shift
done


# CREATE NEW CMVC INSTANCES
if [ $CREATE -eq 1 ]
then
	# ColdMVC's source code will probably be at /etc/
	# When built, this variable will probably be here
	
	# Check that a directory has been specified
	[ -z $DIR ] && err "No directory specified for new instance." $ERR_NODIR	


	# Create a name if not specified
	[ -z $NAME ] && {
		NAME=`basename $DIR`
	}


	# Then default all other variables if they were not specified.
	BASE=${BASE:-""}
	DATASOURCE=${DATASOURCE:-"(none)"}
	TITLE=${TITLE:-"$NAME"}
	DOMAIN=${DOMAIN:-"$NAME"}
	DESCRIPTION=${DESCRIPTION:-""}


	# It's a good time for a message
	[ $VERBOSE -eq 1 ] && {
		printf "Creating new ColdMVC instance with the following parameters.\n"
		#Uses Apache?  `test $NO_GIT -eq 1 && echo "No" || echo "Yes"`
		cat <<EOF
DIR         = $DIR
BASE        = $BASE
DATASOURCE  = $DATASOURCE
DOMAIN      = $DOMAIN
TITLE       = $TITLE
DESCRIPTION = $DESCRIPTION

Uses Git?     `test $NO_GIT -eq 1 && echo "No" || echo "Yes"`
EOF
	}


	# Set up a new CMVC instance
	[ $VERBOSE -eq 1 ] && printf "\n* Create ColdMVC application folders...\n"
	[ $VERBOSE -eq 1 ] && echo mkdir -p $DIR/{app,assets,components,db,files,middleware,routes,log,setup,sql,std,views}
	mkdir -p $DIR/{app,assets,components,db,files,middleware,routes,log,setup,sql,std,views}

	[ $VERBOSE -eq 1 ] && echo mkdir -p $DIR/assets/{css,js,sass,less}
	mkdir -p $DIR/assets/{css,js,sass,less}

	[ $VERBOSE -eq 1 ] && echo mkdir -p $DIR/db/static
	mkdir -p $DIR/db/static

	[ $VERBOSE -eq 1 ] && echo mkdir -p $DIR/std/custom
	mkdir -p $DIR/std/custom


	# Populate the new instance
	[ $VERBOSE -eq 1 ] && printf "\n* Populating new ColdMVC instance...\n"
	[ $VERBOSE -eq 1 ] && echo cp $SRC/share/{Application.cfc,coldmvc.cfc,index.cfm,data.json} $DIR/
	cp $SRC/share/{Application.cfc,coldmvc.cfc,index.cfm,data.json} $DIR/

	[ $VERBOSE -eq 1 ] && echo cp $SRC/share/data.json.example $DIR/std/
	cp $SRC/share/data.json.example $DIR/std/

	[ $VERBOSE -eq 1 ] && echo cp $SRC/share/app-default.cfm $DIR/app/default.cfm
	cp $SRC/share/app-default.cfm $DIR/app/default.cfm

	[ $VERBOSE -eq 1 ] && echo cp $SRC/share/views-default.cfm $DIR/views/default.cfm
	cp $SRC/share/views-default.cfm $DIR/views/default.cfm

	[ $VERBOSE -eq 1 ] && echo cp $SRC/share/failure.cfm $DIR/std/
	cp $SRC/share/failure.cfm $DIR/std/

	[ $VERBOSE -eq 1 ] && echo cp $SRC/share/{4xx,5xx,mime,html}-view.cfm $DIR/std/
	cp $SRC/share/{4xx,5xx,mime,html}-view.cfm $DIR/std/

	[ $VERBOSE -eq 1 ] && echo DONE!

	[ $VERBOSE -eq 1 ] && printf "\n* Setting up redirects...\n"
	for _d in app components db log middleware routes setup sql std views
	do 
		echo cp $SRC/share/Application-Redirect.cfc $DIR/$_d/Application.cfc
		cp $SRC/share/Application-Redirect.cfc $DIR/$_d/Application.cfc
	done

	[ $VERBOSE -eq 1 ] && echo DONE!
#	cp $SRC/share/Application-Redirect.cfc $DIR/components/Application.cfc
#	cp $SRC/share/Application-Redirect.cfc $DIR/db/Application.cfc
#	cp $SRC/share/Application-Redirect.cfc $DIR/middleware/Application.cfc
#	cp $SRC/share/Application-Redirect.cfc $DIR/routes/Application.cfc
#	cp $SRC/share/Application-Redirect.cfc $DIR/setup/Application.cfc
#	cp $SRC/share/Application-Redirect.cfc $DIR/sql/Application.cfc
#	cp $SRC/share/Application-Redirect.cfc $DIR/std/Application.cfc
#	cp $SRC/share/Application-Redirect.cfc $DIR/views/Application.cfc

	[ $VERBOSE -eq 1 ] && printf "\n* Setting up assets...\n"
	cp $SRC/share/*.css $DIR/assets/

	[ $VERBOSE -eq 1 ] && echo DONE!


	# Modify the data.json in the new directory to actually work
	[ $VERBOSE -eq 1 ] && printf "\n* Modifying data.json...\n"
	sed -i "" "{
		s/{{ DATASOURCE }}/${DATASOURCE}/
		s;{{ COOKIE }};`xxd -ps -l 60 /dev/urandom | head -n 1`;
		s;{{ BASE }};/${BASE};
		s/{{ NAME }}/${NAME}/
		s/{{ TITLE }}/${TITLE}/
	}" $DIR/data.json
	[ $VERBOSE -eq 1 ] && echo DONE!


	#Add a changelog
	[ $VERBOSE -eq 1 ] && printf "\n* Generating a CHANGELOG file...\n"
	printf "`date +%F`\n\t- Created this project." > $DIR/CHANGELOG
	[ $VERBOSE -eq 1 ] && echo DONE!


	#Add a README
#	[ $VERBOSE -eq 1 ] && printf "Generating a README file...\n"
#	printf "Give me a short description of this project.\n(Press [Ctrl-D] to save this file...)\n"
#	touch $DIR/README.md
#	cat > $DIR/README.md.USER
#	date > $DIR/README.md.ACTIVE
#	sed 's/^/\t -/' $DIR/README.md.USER >> $DIR/README.md.ACTIVE
#	printf "\n" >> $DIR/README.md.ACTIVE
#	cat $DIR/README.md.ACTIVE $DIR/README.md > $DIR/README.md.NEW
#	rm $DIR/README.md.{ACTIVE,USER}
#	mv $DIR/README.md.NEW $DIR/README.md
# [ $VERBOSE -eq 1 ] && echo DONE!


	#Is a LICENSE needed?
	#[ $VERBOSE -eq 1 ] && printf "Generating a LICENSE...\n"
	#touch $DIR/LICENSE


	#Create git repo 
	[ $NO_GIT -eq 0 ] && {
		[ $VERBOSE -eq 1 ] && printf "\nCreating the Git repository for this project...\n"
		touch $DIR/.gitignore
		cd $DIR
		git init
		{
		echo <<GIT
#Filter out all binary files
*.bmp
*.gif
*.jpg
*.png
*.mp4
*.mov
*.mkv
files/*
log/*
GIT
		} > .gitignore
		git add .
		git commit -m "Standard first commit."
		cd -
		[ $VERBOSE -eq 1 ] && echo DONE!
	}


	#/etc/hosts should be modifiable via here
	#[ $VERBOSE -eq 1 ] && printf "Updating local /etc/hosts file...\n" 
	#printf "127.0.0.1\t$DEV_DOMAIN\t$DEV_ALIAS\n#End of file\n" >> $HOSTS_FILE


	#Generate the scaffolding for a new VirtualHost for Lucee
	HOST_CONTENT=$(cat <<LUCEE_HOST
	\t\t<!-- #BEGIN:$NAME -->\n\t\t<Host name="${NAME}" appBase="webapps">\n\t\t\t<Context path="" docBase="${DIR}" />\n\t\t\t<Alias>${DEV_ALIAS}</Alias>\n\t\t</Host>\n\t\t<!-- #END:$NAME -->\n
LUCEE_HOST
	) #This is the end of variable declaration


	#Create a new VirtualHost for Lucee
	#sed -i "{ s|\(<!-- ADD NEW HOSTS HERE -->\)|\1\n${HOST_CONTENT}| }" $LUCEE_CONF

fi



	#cp $SRC/share/apache_htaccess $DIR/.htaccess
