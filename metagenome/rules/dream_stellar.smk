rule dream_stellar_search:
	input:
		ref_seg = "{b}/bins/bin_{bin}.fasta",
		query = "/dev/shm/{b}/queries/bin_{bin}_e{er}.fasta"
	output:
		"{b}/dream_stellar/bin_{bin}_e{er}.gff"
	params:
		e = get_search_error_rate
	conda:
		"../envs/stellar.yaml"
	benchmark:
		"benchmarks/{b}/dream_stellar/bin_{bin}_e{er}.txt"
	shell:
		"stellar --verbose {input.ref_seg} {input.query} -e {params.e} -l {pattern} -a dna -o {output}"
	
