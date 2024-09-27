#!/usr/bin/env bash
set -x

er="0.025"
timeout="1m"
k=14
for t in 9 10 11
do
	./search.sh $er $k $t $timeout 2> ${er}_${k}_${t}.err 
done

k=15
for t in 6 7 8 9
do
	./search.sh $er $k $t $timeout 2> ${er}_${k}_${t}.err 
done

k=16
for t in 3 4 5
do
	./search.sh $er $k $t $timeout 2> ${er}_${k}_${t}.err 
done

er="0.05"
timeout="3m"
k=11
for t in 8 9 10
do
	./search.sh $er $k $t $timeout 2> ${er}_${k}_${t}.err 
done

for k in 14 15
do
	for t in 4 5 6
	do
		./search.sh $er $k $t $timeout 2> ${er}_${k}_${t}.err
	done
done

#er="0.075"
#timeout="10m"
#k=11
#for t in 8 9 10
#do
#	./search.sh $er $k $t $timeout 2> ${er}_${k}_${t}.err 
#done

#for k in 13 14
#do
#	for t in 1 2
#	do
#		./search.sh $er $k $t $timeout 2> ${er}_${k}_${t}.err
#	done
#done

#er="0.1"
#timeout="45m"
#for k in 12 13
#do
#	for t in 3 4
#	do
#		./search.sh $er $k $t $timeout 2> ${er}_${k}_${t}.err
#	done
#done
