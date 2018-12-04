#!/bin/bash

mapfile=(`ls map`)
echo ${mapfile[@]}

echo > result.txt

for mf in ${mapfile[@]}
do

	for i in `seq 1 10`
	do

		ruby chsr08.rb -w .0 -s -e ./exec2s.sh -r -t 100 -m map/$mf

	done

done

echo COOL
grep COOL result.txt | wc -l
echo HOT
grep HOT result.txt | wc -l
