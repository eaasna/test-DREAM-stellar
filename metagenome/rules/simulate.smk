rule simulate_database:
	output:
		ref = "{bins}/ref.fasta",
		bins = expand("{{bins}}/bins/bin_{bin}.fasta", bin = bin_list),
		bin_paths = "{bins}/bin_paths.txt",
	params:
		ref_seed = get_seed
	shell:      
		"../scripts/simulate_database.sh {ref_len} {params.ref_seed} {bins} {ht}"

rule simulate_reads:
	input:
		ref = expand("{{bins}}/bins/bin_{bin}.fasta", bin = bin_list)
	output:
		matches = "{bins}/queries/e{er}.fastq",
		bin_query_paths = "{bins}/e{er}_bin_query_paths.txt"
	params: 
		errors = get_simulation_error_count
	shell:      
		"../scripts/simulate_reads.sh {bins} {ht} {params.errors} {wildcards.er} {match_len} {matches}"

