rule simulate_database:
	output:
		ref = "{b}/ref.fasta",
		bins = expand("{{b}}/bins/bin_{bin}.fasta", bin = bin_list),
		bin_paths = "{b}/bin_paths.txt",
	params:
		ref_seed = get_seed
	shell:      
		"../scripts/simulate_database.sh {ref_len} {params.ref_seed} {wildcards.b} {haplotype_count}"

rule simulate_reads:
	input:
		ref = expand("{{b}}/bins/bin_{bin}.fasta", bin = bin_list)
	output:
		matches = "{b}/queries/e{er}.fastq",
		bin_query_paths = "{b}/e{er}_bin_query_paths.txt"
	params: 
		errors = get_simulation_error_count
	shell:      
		"../scripts/simulate_reads.sh {wildcards.b} {haplotype_count} {params.errors} {wildcards.er} {match_length} {matches}"

