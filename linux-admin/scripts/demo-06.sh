#!/bin/bash
#if [ $# -eq 0 ]; then
if test $# -eq 0 ; then
  echo "Require two arguments (numbers)"	
else
  N1=$1
  N2=$2
  N3=$((N1+N2))
  echo "Sum : $N3"
fi
