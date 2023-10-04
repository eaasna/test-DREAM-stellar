#!/usr/bin/env bash

set -e

REF_FILE=$1
REP=$2
SEED=$3
ERRORS=$4
ERROR_COUNT=$5
READ_LENGTH=$6
READ_COUNT=$7

echo "Generating $READ_COUNT reads of length $READ_LENGTH with $ERRORS errors"
read_dir=reads_rep$REP\_e$ERROR_COUNT\_l$READ_LENGTH
mkdir -p $read_dir
generate_reads \
    --output $read_dir \
    --max_errors $ERRORS \
    --number_of_reads $READ_COUNT \
    --genome \
    --read_length $READ_LENGTH \
    $REF_FILE
