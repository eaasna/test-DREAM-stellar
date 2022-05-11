#!/usr/bin/env bash
set -e

BIN_NUMBER=$1
ERROR_RATE=$2
OUTFILE=$3

seq -f "/dev/shm/queries/bin_%0${#BIN_NUMBER}g_e${ERROR_RATE}.fasta" 0 1 $((BIN_NUMBER-1)) > $OUTFILE
