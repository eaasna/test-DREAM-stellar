#!/usr/bin/env bash
set -e

REF_LENGTH=$1 	# 2^20 = 1Mb
REF_SEED=$2

execs=(mason_genome mason_variator)
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
mason_genome -l $REF_LENGTH -o ${3} -s $REF_SEED


sv_rate=0.0001
echo "Simulating a related genome"
mason_variator -s $REF_SEED --in-reference ${3} --out-vcf query.vcf --out-fasta ${4} --snp-rate 0.001 --small-indel-rate $sv_rate --sv-indel-rate $sv_rate --sv-inversion-rate $sv_rate --sv-translocation-rate $sv_rate --sv-duplication-rate $sv_rate
