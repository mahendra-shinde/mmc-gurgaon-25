#!/bin/bash
# for EACH file "fn" in current directory
for fn in *.sh ; do
	# print a message
	echo "Make the file $fn executable ... "
	# set executable permission for the file
	chmod +x $fn
done
