#!/usr/bin/env bash

size=${1}
er=0.05
bins=64

#snakemake --cores 1 --snakefile Snakefile_simulate --configfile $size/config.yaml --config error_rate=$er ibf_bins=$bins --
#( /usr/bin/time -a -o $size/stellar.time -f "%e\t%M\t%x\t%C" snakemake --cores 16 --snakefile Snakefile_stellar --configfile $size/config.yaml --config error_rate=$er ibf_bins=$bins -- ) 2> $size/stellar.err

#for p in 0.15 0.25 0.5 0.75 1.0
for p in 1.0
do
( /usr/bin/time -a -o $size/p$p\_dream.time -f "%e\t%M\t%x\t%C" snakemake --forceall --cores 16 --snakefile Snakefile_dream --configfile $size/config.yaml --config threshold_p=$p error_rate=$er ibf_bins=$bins -- ) 2> $size/dream.err
rm -r /dev/shm/$bins/queries
done

#snakemake --cores 1 --snakefile Snakefile_evaluate --configfile $size/config.yaml --config threshold_p=$p_max error_rate=$er ibf_bins=$bins --

