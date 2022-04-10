def get_float_er(wildcards):
        if (wildcards.er=="0"):
                # minimum allowed error rate should be 1e-7
                a = 1e-5          # but 1e-7 and 1e-6 lead to invalid pointer error
                return f'{a:.5f}' # supress scientific notation 
        return float(wildcards.er[:1] + '.' + wildcards.er[1:])

num = config["num_matches"]
tresh = config["sort_threshold"]

rule stellar:
        input:
                ref = "ref_rep{rep}.fasta",
                query = "query/with_insertions_rep{rep}_e{er}.fasta"
        output: 
                "stellar/rep{rep}_e{er}.gff"
        params:
                e = get_float_er
        benchmark:
                "benchmarks/stellar_rep{rep}_e{er}.txt"
        conda:
                "../envs/stellar.yaml"
        shell:
                "stellar {input.ref} {input.query} --forward -e {params.e} -l {min_len} --numMatches {num} --sortThresh {tresh} -a dna -o {output}"

