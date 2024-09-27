#!/usr/bin/env bash
set -x

#snakemake --use-conda --cores 8 --configfile 1kb/config.yaml
#snakemake --use-conda --cores 8 --configfile 10kb/config.yaml

#for size in "100kb" "1Mb" "10Mb" "100Mb"
#for magic_const in "0.01" "0.025" "0.05" "0.075"
for magic_const in "0.1"
do
	export PATH="/group/ag_abi/evelina/valik/build_${magic_const}/bin:$PATH"
	size="100Mb_$magic_const"
	snakemake --rerun-incomplete --forceall --keep-going --cores 16 --configfile ${size}/config.yaml 1> ${size}.out 2> ${size}.err
	#rm $size/*.minimiser
	#rm $size/*.header
done

rm -r /tmp/valik/stellar_call*
#python scripts/make_stellar_table2.py
