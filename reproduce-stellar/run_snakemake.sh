#!/usr/bin/env bash
set -x

#snakemake --use-conda --cores 8 --configfile 1kb/config.yaml
#snakemake --use-conda --cores 8 --configfile 10kb/config.yaml

#for size in "100kb" "1Mb" "10Mb" "100Mb"
for size in "10Mb"
do
	snakemake --rerun-incomplete --forceall --keep-going --cores 16 --configfile ${size}/config.yaml 1> ${size}.out 2> ${size}.err
done

#python scripts/make_stellar_table2.py
