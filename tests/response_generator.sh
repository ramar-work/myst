#!/bin/bash
# Test generator for 'renderPage' and possibly other web application builders...
CTYPES[0]="text/html" 
CTYPES[1]="application/json"
CTYPES[2]="application/xml"
CTYPES[3]="text/plain"

EXCEPTIONS[0]="Database"
EXCEPTIONS[1]="Application"
EXCEPTIONS[2]="Template"
EXCEPTIONS[3]="Object"
EXCEPTIONS[4]="Expression"
EXCEPTIONS[5]="Security"
EXCEPTIONS[6]="Lock"
EXCEPTIONS[7]="MissingInclude"
EXCEPTIONS[8]="Any"

function output() {
	printf "{"
	printf "status=$1,"
	printf "content=$2,"
	printf "content_type='$3',"
	printf "err=${4:-{}},"
	printf "exception=${5:-''}"
	printf "},\n"
}

printf "["
for n in `seq 200 226` `seq 300 307` `seq 400 451` `seq 500 511`
do
	for c in ${CTYPES[@]}
	do
		output $n "'Hello, World'" "$c"
		output $n '{ a="b", c="d", e="f" }' "$c"
	done
done

# Test exceptions here
for n in ${EXCEPTIONS[@]}
do
	for c in ${CTYPES[@]}
	do
		output 200 "'Hello, World'" "$c" "" "'$n'"
		output 200 '{ a="b", c="d", e="f" }' "$c" "" "'$n'"
	done
done

printf "]\n"


