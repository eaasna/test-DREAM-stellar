f = open("stellar.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
        f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

rule convert_query:
	input:
		query = "queries/e{er}.fastq"
	output:
		query = "queries/e{er}.fasta"
	shell:
		"sed -n '1~4s/^@/>/p;2~4p' {input} > {output}"
rule stellar_search:
	input:
		ref = "ref.fasta",
		query = "queries/e{er}.fasta"
	output:
		"search/stellar_e{er}.gff"
	params:
		e = get_search_error_rate
	shell:
		"""
		( /usr/bin/time -a -o stellar.time -f "%e\t%M\t%x\tstellar-search" ../../../bin/miniconda3/envs/snakemake/bin/stellar -a dna --verbose {input.ref} {input.query} -e {params.e} -l {pattern}  -o {output})
		"""
