#!/bin/bash

set -e

if [[ "$#" -ne 2 ]]; then
	echo "Usage: bash find_inversion.sh <work_dir> <seq_in>"
	exit 1
fi

work_dir=$1
matches=$2

cd $work_dir 
mkdir -p potential_inversions

awk '$7 == "+" {print}' $matches > forward_matches.gff
awk '$7 == "-" {print}' $matches > reverse_matches.gff

awk '{print $9}' $matches | awk -F';' '{print $1}' | sort | uniq > qnames

ind=1
while read id; 
do
	#echo -e "qname\t$id"
	#echo -e "ind\t$ind"
	grep $id $matches > $ind.gff
	awk '{print $1}' $ind.gff | sort | uniq > chr_hits
	while read chr;
	do
		found_inversion=0
		if [ "$chr" != "Concatenated" ]; then
			#echo -e "chr\t$chr"
			grep $id forward_matches.gff | awk -v chr_id="$chr" ' $1==chr_id ' > curr_forward.gff
			grep $id reverse_matches.gff | awk -v chr_id="$chr" ' $1==chr_id ' > curr_reverse.gff
			
			#forward_alignments=$(wc -l curr_forward.gff | awk '{print $1}')
			#reverse_alignments=$(wc -l curr_reverse.gff | awk '{print $1}')
			
			start_table="$ind.dstart.forward.tsv"
			awk '{print $4}' curr_forward.gff | cut -c1-3 | sort | uniq -c > $start_table
			forward_same_ref_region=$(awk '$1>1 {print}' $start_table | wc -l | awk '{print $1}')
			rm $start_table

			start_table="$ind.dstart.reverse.tsv"
			awk '{print $4}' curr_reverse.gff | cut -c1-3 | sort | uniq -c > $start_table
			reverse_same_ref_region=$(awk '$1>1 {print}' $start_table | wc -l | awk '{print $1}')
			rm $start_table
			
			# same_ref_region=$((forward_same_ref_region+reverse_same_ref_region))
			# find read that matches on forward and reverse strand of the same chr
			if [ $forward_same_ref_region -ge 1 ] && [ $reverse_same_ref_region -ge 1 ]; then
				grep $id $matches | awk -v chr_id="$chr" ' $1==chr_id '  > potential_inversions/${chr}_${ind}.gff
		
				start_table="$ind.qstart.tsv"
				end_table="$ind.qend.tsv"	
				awk '{print $9}' potential_inversions/${chr}_$ind.gff | awk -F';' '{print $2}' | sed 's/seq2Range=//g' | awk -F',' '{print $1}' | sort | uniq -c > $start_table
				awk '{print $9}' potential_inversions/${chr}_$ind.gff | awk -F';' '{print $2}' | sed 's/seq2Range=//g' | awk -F',' '{print $2}' | sort | uniq -c > $end_table
				
				unique_starts=$(awk '$1<2 {print}' $start_table | wc -l | awk '{print $1}')
				unique_ends=$(awk '$1<2 {print}' $end_table | wc -l | awk '{print $1}')
				if [ $unique_starts -ge 2 ] && [ $unique_ends -ge 2 ]; then
					
					max_start=$(tail -n 1 $start_table | awk '{print $2}')
					min_start=$(head -n 1 $start_table | awk '{print $2}')
					max_end=$(tail -n 1 $end_table | awk '{print $2}')
					min_end=$(head -n 1 $end_table | awk '{print $2}')
					start_range=$(($max_start-$min_start))
					end_range=$(($max_end-$min_end))
					
					#echo "$unique_starts"
					#echo "$unique_ends"
					#echo -e "max start\t$max_start"
					#echo -e "min start\t$min_start"
					#echo -e "max end\t$max_end"
					#echo -e "min end\t$min_end"
					#echo -e "start range\t$start_range"
					#echo -e "end range\t$end_range"
					#exit 1
					if [ $start_range -ge 100 ] && [ $end_range -ge 100 ]; then

						echo -e "\tForward\t$forward_alignments"
						echo -e "\tReverse\t$reverse_alignments"
						echo "Potential inversions for read $id on $chr"
						found_inversion=1
					fi
				fi
				rm $start_table
				rm $end_table
				
				if [ $found_inversion -eq 0 ]; then
					rm potential_inversions/${chr}_$ind.gff
				fi
			fi
		fi
	done < chr_hits
	rm $ind.gff
	ind=$(($ind+1))
done < qnames

