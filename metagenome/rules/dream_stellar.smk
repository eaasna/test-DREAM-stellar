rule distribute_search:
	input:
		queries = "rep{rep}/queries/e{er}.fastq",
		search_out = "rep{rep}/search/e{er}.out"
	output:
		temp(expand("/dev/shm/rep{{rep}}/queries/bin_{bin}_e{{er}}.fasta", bin = bin_list))
	params:
		out_prefix = "/dev/shm/rep{rep}/queries/"
	benchmark:
		"benchmarks/rep{rep}/dream_stellar/distribute_search_e{er}.txt"
	script:
		"../scripts/distribute_search.py"

rule dream_stellar_search:
	input:
		ref_seg = "rep{rep}/bins/bin_{bin}.fasta",
		query = "/dev/shm/rep{rep}/queries/bin_{bin}_e{er}.fasta"
	output:
		"rep{rep}/dream_stellar/bin_{bin}_e{er}.gff"
	params:
		e = get_error_rate
	benchmark:
		"benchmarks/rep{rep}/dream_stellar/bin_{bin}_e{er}.txt"
	shell:
		"""
		if [ -s {input.query} ]; then
		        # Search queries for current bin
			stellar --verbose {input.ref_seg} {input.query} --forward -e {params.e} -l {pattern} --numMatches {num} --sortThresh {thresh} -a dna -o {output}
		else
			touch {output} # create dummy output
		fi
		"""
	
