f = open("stellar.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\tParams\n")
f.close()

rule convert_to_fasta:
	input:
		mutex = "{b}/blast_table1.tsv",
		fastq = "{b}/queries/e{er}.fastq"
	output:
		fasta = "{b}/queries/e{er}.fasta"
	shell:
		"sed -n '1~4s/^@/>/p;2~4p' {input} > {output}"

rule stellar_search:
	input:
		ref = "{b}/ref.fasta",
		query = "{b}/queries/e{er}.fasta"
	output:
		"{b}/stellar/e{er}.gff"
	params:
		e = get_search_error_rate
	benchmark:
		"benchmarks/stellar_e{er}_b{b}.txt"
	shell:
		"""
		( timeout 1h /usr/bin/time -a -o stellar.time -f "%e\t%M\t%x\tstellar\ter={wildcards.er}" ../../../stellar3/build/bin/stellar --verbose {input.ref} {input.query} -e {params.e} -l {min_len} -a dna -o {output} || touch {output} )
		"""
	
