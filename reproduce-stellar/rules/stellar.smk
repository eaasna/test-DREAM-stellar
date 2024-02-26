rule stellar:
        input:
                ref = "ref_rep{rep}.fasta",
                query = "query/rep{rep}_e{er}.fasta"
        output: 
                "stellar/rep{rep}_e{er}.gff"
        params:
                e = get_search_error_rate
        benchmark:
                "benchmarks/stellar_rep{rep}_e{er}.txt"
        shell:
                """( /usr/bin/time -a -o stellar.time -f "%e\t%M\t%x\tstellar-search\t{wildcards.er}" ../../../stellar3/build/bin/stellar -a dna --numMatches {num_matches}  --sortThresh {sort_thresh} {input.ref} {input.query} -e {params.e} -l {min_len} -o {output} )"""
                #"""( /usr/bin/time -a -o stellar.time -f "%e\t%M\t%x\tstellar-search\t{wildcards.er}" ../../../bin/miniconda3/envs/snakemake/bin/stellar -a dna --numMatches {num_matches}  --sortThresh {sort_thresh} {input.ref} {input.query} -e {params.e} -l {min_len} -o {output} )"""
