#!/bin/bash
mapfile=(`ls map`)

echo > result.txt

for mf in ${mapfile[@]}
do
	ruby chsr08.rb -w .0 -s -e ./exec2s.sh -r -t 150 -m map/$mf
done

grep COOL result.txt | wc -l