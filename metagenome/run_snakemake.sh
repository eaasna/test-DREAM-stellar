#!/usr/bin/env bash

mkdir -p /dev/shm/valik
export VALIK_TMP=/dev/shm/valik
export VALIK_STELLAR=/group/ag_abi/evelina/stellar3/build/bin/stellar
for size in "10Mb"
do
	snakemake --cores 16 --snakefile Snakefile --configfile $size/config.yaml > $size.out 2> $size.err
done

rm /dev/shm/valik/*.gff
