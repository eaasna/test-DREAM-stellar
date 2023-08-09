#!/usr/bin/env bash

size=${1}

mkdir -p /dev/shm/valik
export VALIK_TMP=/dev/shm/valik
export VALIK_STELLAR=/group/ag_abi/evelina/stellar3/build/bin/stellar

snakemake --cores 16 --configfile $size/config.yaml 

rm /dev/shm/valik/*.gff
