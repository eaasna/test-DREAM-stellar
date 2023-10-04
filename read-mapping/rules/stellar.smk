f = open("stellar.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

rule stellar:
	input:
		ref = "dmel.fasta",
		query = "reads_rep{rep}_e{er}_l{len}/dmel.fasta"
	output: 
		"stellar/rep{rep}_e{er}_l{len}.gff"
	params:
		er = get_search_error_rate
	conda:
		"../envs/stellar.yaml"
	shell:
		"""
		( /usr/bin/time -a -o stellar.time -f "%e\t%M\t%x\tstellar-search" ../../../bin/miniconda3/envs/snakemake/bin/stellar -a dna --numMatches 65534 --sortThresh 65535 --verbose {input.ref} {input.query} -e {params.er} -l {min_len} -o {output} )
		"""
