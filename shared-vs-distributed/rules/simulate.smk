rule simulate_database:
	output:
		ref = "ref.fasta"
	params:
		ref_seed = get_seed
	shell:      
		"../scripts/simulate_reference.sh {ref_len} {params.ref_seed}"

rule simulate_reads:
	input:
		"ref.fasta"
	output:
		matches = "queries/e{er_rate}.fasta"
	shell:      
		"../scripts/simulate_local_matches.sh {output} {wildcards.er_rate} {matches} {match_len} {ref_len}"

