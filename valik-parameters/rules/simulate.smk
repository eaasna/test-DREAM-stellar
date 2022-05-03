rule simulate_database:
	output:
		ref = expand("bins/bin_{bin}.fasta", bin = bin_list),
		meta = "bin_paths.txt"
	params:
		ref_seed = get_seed
	shell:      
		"../scripts/simulate_database.sh {ref_len} {params.ref_seed} {bins} {ht}"

rule simulate_reads:
	input:
		ref = expand("bins/bin_{bin}.fasta", bin = bin_list)
	output:
		matches = "queries/e{er}.fastq"
	params: 
		errors = get_simulation_error_count
	shell:      
		"../scripts/simulate_reads.sh {bins} {ht} {params.errors} {wildcards.er} {match_len} {matches}"
