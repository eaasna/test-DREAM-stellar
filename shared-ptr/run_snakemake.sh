#!/usr/bin/env bash

size=${1}

mkdir -p /dev/shm/valik

snakemake --forceall --cores 16 --configfile $size/config.yaml 

