#!/usr/bin/env bash

size=${1}

mkdir -p /dev/shm/valik
export VALIK_TMP=/dev/shm/valik
export VALIK_STELLAR=/group/ag_abi/eaasna/stellar3/build/bin/stellar

snakemake --forceall --cores 1 --snakefile Snakefile_simulate --configfile $size/config.yaml
snakemake --forceall --cores 16 --snakefile Snakefile_dream --configfile $size/config.yaml
#snakemake --forceall --cores 16 --snakefile Snakefile_dream --configfile $size/64_config.yaml 
#snakemake --forceall --cores 16 --snakefile Snakefile_dream --configfile $size/128_config.yaml 
#snakemake --forceall --cores 16 --snakefile Snakefile_dream --configfile $size/1024_config.yaml 
#snakemake --forceall --cores 16 --snakefile Snakefile_dream --configfile $size/2048_config.yaml 
snakemake --forceall --cores 1 --snakefile Snakefile_stellar --configfile $size/config.yaml 2> $size/stellar.err

rm /dev/shm/valik/*.gff
