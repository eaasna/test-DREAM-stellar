f = open("stellar.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

rule stellar:
        input:
                ref = "genomeA_rep{rep}.fasta",
                query = "genomeB_rep{rep}.fasta"
        output: 
                "stellar/rep{rep}.gff"
        params:
                e = get_search_error_rate
        shell:
                """
		( /usr/bin/time -a -o stellar.time -f "%e\t%M\t%x\tstellar-search" ../../../bin/miniconda3/envs/snakemake/bin/stellar -a dna --numMatches {num_matches} --sortThresh {sort_thresh} --verbose {input.ref} {input.query} -e {params.e} -l {min_len} -o {output} )
		"""
