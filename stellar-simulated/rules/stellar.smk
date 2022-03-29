def get_float_er(wildcards):
        if (wildcards.er=="0"):
                # minimum allowed error rate should be 1e-7
                a = 1e-5          # but 1e-7 and 1e-6 lead to invalid pointer error
                return f'{a:.5f}' # supress scientific notation 
        return float(wildcards.er[:1] + '.' + wildcards.er[1:])

rule stellar:
        input:
                ref = "ref.fasta",
                query = "query/with_insertions_{er}.fasta"
        output: 
                "stellar/{er}.gff"
        params:
                e = get_float_er
        benchmark:
                repeat("benchmarks/stellar_{er}.txt", 5)
        conda:
                "../envs/stellar.yaml"
        shell:
                "stellar {input.ref} {input.query} -e {params.e} -l {min_len} -a dna -o {output}"

