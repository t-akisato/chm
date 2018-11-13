#!/bin/bash
echo > result.txt
for i in `seq 1 10`
do
ruby chsr08.rb -w .0 -s -e ../test/exec2s.sh -r -t 200 -m map/m000.map
done
echo COOL
grep COOL result.txt | wc -l
echo HOT
grep HOT result.txt | wc -l
