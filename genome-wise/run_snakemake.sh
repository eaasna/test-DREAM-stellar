#!/usr/bin/env bash
set -x

snakemake --forceall --rerun-incomplete --configfile config.yaml --keep-going --cores 16 1> search.out 2> search.err
