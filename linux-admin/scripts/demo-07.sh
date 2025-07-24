#!/bin/bash
if [ $# -lt 3 ]; then
#if test $# -lt 3 ; then
  echo "Require Three arguments (number1 operator number2)"	
  echo "Supported Operators : + - x %"
else
  N1=$1
  N2=$3
  OP=$2
  if [ "$OP" = "+" ]; then N3=$((N1+N2)); fi
  if [ "$OP" = "-" ]; then N3=$((N1-N2)); fi
  if [ "$OP" = "x" ]; then N3=$((N1*N2)); fi
  if [ "$OP" = "%" ]; then N3=$((N1/N2)); fi
  echo "Answer :$N3"
fi
