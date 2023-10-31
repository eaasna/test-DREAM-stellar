#!/usr/bin/env bash
set -x

#snakemake --use-conda --cores 8 --configfile 1kb/config.yaml
#snakemake --use-conda --cores 8 --configfile 10kb/config.yaml

for size in "100kb" "1Mb" "10Mb" "100Mb"
do
	snakemake --use-conda --forceall --cores 8 --configfile ${size}/config.yaml > ${size}.log
done

#python scripts/make_stellar_table2.py
