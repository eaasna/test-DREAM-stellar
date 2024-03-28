#!/usr/bin/env bash
set -x

snakemake --forceall --cores 16 1> search.out 2> search.err
