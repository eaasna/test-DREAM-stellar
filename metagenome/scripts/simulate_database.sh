#!/usr/bin/env bash
set -e

execs=(mason_genome generate_reads split_sequence mason_variator)
for exec in "${execs[@]}"; do
    if ! which ${exec} &>/dev/null; then
        echo "${exec} is not available"
        echo ""
        echo "make sure \"${execs[@]}\" are reachable via the \${PATH} variable"
        echo ""

        # trying to do some guessing here:
        paths+=(../../lib/raptor_data_simulation/build/bin)
        paths+=(../../lib/raptor_data_simulation/build/src/mason2/src/mason2-build/bin)

        p=""
        for pp in ${paths[@]}; do
            p=${p}$(realpath -m $pp):
        done
        echo "you could try "
        echo "export PATH=${p}\${PATH}"

        exit 127
    fi
done

# reference parameters
LENGTH=$1
SEED=$2
BIN_NUMBER=$3
HAPLOTYPE_COUNT=$4

work_dir="${BIN_NUMBER}"
mkdir -p $work_dir
cd $work_dir

bin_dir=bins
info_dir=info

mkdir -p $bin_dir
mkdir -p $info_dir

bin_length=$((LENGTH / BIN_NUMBER))
echo "Simulating $BIN_NUMBER bins with reference length of $LENGTH and bin_length of $bin_length"
# Simulate reference
echo "Simulating genome"
mason_genome -l $LENGTH -o $bin_dir/ref.fasta -s $SEED

# Evenly distribute it over bins
echo "Splitting genome into bins"
split_sequence --input $bin_dir/ref.fasta --length $bin_length --parts $BIN_NUMBER
# We need the complete reference for Stellar input
rm $bin_dir/ref.fasta
# Rename the bins to .fa
for i in $bin_dir/*.fasta; do mv $i $bin_dir/$(basename $i .fasta).fa; done
# Simulate haplotypes for each bin
echo "Generating haplotypes"
for i in $bin_dir/*.fa
do
   mason_variator \
       -ir $i \
       -n $HAPLOTYPE_COUNT \
       -of $bin_dir/$(basename $i .fa).fasta \
       -ov $info_dir/$(basename $i .fa).vcf	
   rm $i
   rm $i.fai
done

cat $bin_dir/*.fasta > ref.fasta

seq -f "$work_dir/bins/bin_%0${#BIN_NUMBER}g.fasta" 0 1 $((BIN_NUMBER-1)) > bin_paths.txt

mkdir -p valik
mkdir -p stellar
