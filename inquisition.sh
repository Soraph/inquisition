#!/bin/bash

ereticlist="${1}"
originalfile="${2}"

if [ $# -ne 2 ]; then
	echo ""
	echo "	Usage: $0 <list> <target file>"
	echo "	<list> is a file containg the list of unused classes that need to be removed, 1 per line, no trailing {"
	echo "	<target file> is a non minified CSS file (1 line 1 rule)"
	echo ""
	exit
fi

function speak() { 
 echo "[$(date +%H:%M:%S)] $@"
}

function checkforeresy() {
 if [ -e "$@" ]; then
	if [ ! -r "$@" ]; then
	 	#If it exist but is not readable we notify and skip the database optmization
		speak "[NOTICE] $@ not readable, quitting."
		exit
	fi
 else
	speak "[ERROR] $@ doesn't exist, quitting."
	exit
 fi
}

speak "Beginning inquisition"

checkforeresy "$ereticlist"
checkforeresy "$originalfile"

if [ -e "clean-${originalfile}" ]; then
	speak "[ERROR] clean-${originalfile} already exist, remove it before executing this script again, quitting."
	exit
fi

initiallines=$( cat "${originalfile}" | wc -l )
speak "Detected ${initiallines} lines in ${originalfile}"

cp "${originalfile}" clean-"${originalfile}"
cleanfile="clean-${originalfile}"

speak "Created ${cleanfile}"

cat "${ereticlist}" | while read eretic; do
	grep -v "^${eretic} {" "${cleanfile}" > "1-${cleanfile}"
	mv "1-${cleanfile}" "${cleanfile}"
	grep -v "^${eretic}{" "${cleanfile}" > "1-${cleanfile}"
	mv "1-${cleanfile}" "${cleanfile}"
done

newlines=$( cat "${cleanfile}" | wc -l )
finallines=$(( (${initiallines} - ${newlines}) ))

speak "Removed ${finallines} lines."