#!/bin/bash
do_sum( ) {
  local n1=$1
  local n2=$2
  local n3=$((n1+n2))
  echo "$n3"  
}
ans=$(do_sum 10 20)
echo "Answer: $ans"
ans=$(do_sum 23 43)
echo "Answer: $ans"

