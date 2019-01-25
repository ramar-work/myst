#!/bin/bash -
# All of myst's Bash dependencies go here 

# Check for dependencies
check() {
	if [ -z "$1" ]
	then 
		printf "check(): No list specified.  Fix this.\n"
		exit 1
	fi	

	IFS='|'
	for n in $1
	do 
		sh -c ${n} 2>/dev/null
		if [ $? -eq 127 ]
		then 
			printf "$PROGRAM_NAME: Dependency '$n' not found.  " > /dev/stderr
			printf "Please install package '$n' using a package manager.\n" > /dev/stderr
		fi
	done
	IFS=" "
}



# Determine whether an argument is a flag or not
detFlag() {
	if [ -z "$1" ]
	then
		echo -1 
	else
		# arg is a single, lonely dash
		if [ ${#1} -eq 1 ] && [ $1 == '-' ] 
		then
			echo 0

		# arg is a short arg flag 
		elif [ ${1:0:1} == '-' ] && [[ ${1:1:1} =~ [a-z] ]]
		then
			echo -1 

		# arg is a long arg flag 
		elif [ ${1:0:1} == '-' ] && [ ${1:1:1} == '-' ]
		then
			echo -1 

		# arg is an arg
		else
			echo 1

		fi
	fi
}
# Some tests
#detFlag "boss"
#detFlag "-a"
#detFlag "-"
#detFlag "--achoo"
#exit

