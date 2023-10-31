#!/usr/bin/env bash
set -e

REP=$1 # gives a unique name to each output file
REF_LENGTH=$2 	# 2^20 = 1Mb
QUERY_LENGTH=$3 	# 2^20 = 1Mb
REF_SEED=$4
QUERY_SEED=$5

execs=(mason_genome mason_variator generate_local_matches)
for exec in "${execs[@]}"; do
    if ! which ${exec} &>/dev/null; then
        echo "${exec} is not available"
        echo ""
        echo "make sure \"${execs[@]}\" are reachable via the \${PATH} variable"
        echo ""

        # trying to do some guessing here:
        paths+=(../../lib/raptor_data_simulation/build/bin)
        paths+=(../../lib/raptor_data_simulation/build/src/mason2/src/mason2-build/bin)

        p=""
        for pp in ${paths[@]}; do
            p=${p}$(realpath -m $pp):
        done
        echo "you could try "
        echo "export PATH=${p}\${PATH}"

        exit 127
    fi
done

echo "Simulating reference of length $REF_LENGTH with seed $REF_SEED"
mason_genome -l $REF_LENGTH -o ref_rep$REP.fasta -s $REF_SEED 

echo "Simulating query of length $QUERY_LENGTH with seed $QUERY_SEED"
mason_genome -l $QUERY_LENGTH -o random_rep$REP.fasta -s $QUERY_SEED

