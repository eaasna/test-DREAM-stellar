#!/usr/bin/env bash
set -x

er="0.025"
timeout="1m"
k=14
for t in 10
do
	./search.sh $er $k $t $timeout #2> ${er}_${k}_${t}.err 
done

