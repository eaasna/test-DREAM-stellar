#!/bin/bash

set -e

size=100Mb
infile=${size}.out

scp -r evelina@agrippina:/group/ag_abi/evelina/DREAM-stellar-benchmark/reproduce-stellar/${infile} /home/evelin/DREAM-Stellar-presentation/work-python/

grep -A 14 "\-FNR\-" ${infile} | grep -v "\-FNR\-" | sed 's/--//g' > fnr.tsv
grep -A 14 "FP per pattern" ${infile} | grep -v "FP per pattern" | sed 's/--//g' > fpr.tsv

error_array=(4 5)
for type in fnr fpr
do
	i=0
	grep -n "t=" ${type}.tsv | while read -r line
	do
		echo $line

    		IFS=':' read -ra my_array <<< "$line"
    		start="${my_array[0]}"
    		end=$(($start + 13))
	
		echo ${type}_"${error_array[$i]}".tsv
		#echo "start=$start"
		#echo "end=$end"
		sed -n "${start},${end}p" $type.tsv > ${type}_"${error_array[$i]}".tsv

    		i=$(($i+1))
	done
done

