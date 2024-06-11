f = open("stellar.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tParams\n")
f.close()

rule stellar:
	input:
		ref = "/buffer/ag_abi/evelina/human_dna4.fa",
		query = "/buffer/ag_abi/evelina/mouse/dna4.fa",
	output: 
		"stellar_e{er}.gff"
	benchmark:
		"benchmarks/stellar_e{er}.txt"
	shell:
		"""
		( timeout 6h /usr/bin/time -a -o stellar.time -f "%e\t%M\t%x\tstellar-search\ter={wildcards.er}" ../../stellar3/build/bin/stellar -a dna --numMatches {num_matches} --sortThresh {sort_thresh} {input.ref} {input.query} -e {wildcards.er} -l {min_len} -o {output} || touch {output} )
		"""
