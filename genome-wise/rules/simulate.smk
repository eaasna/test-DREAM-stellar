rule simulate_input_sequences:
	output:
		ref = "genomeA_rep{rep}.fasta",
		query = temp("random_rep{rep}.fasta")
	params:
		ref_seed = get_seed,
		query_seed = get_seed
	shell:      
		"../scripts/simulate_sequences.sh {wildcards.rep} {ref_len} {params.ref_seed} {params.query_seed}"

rule simulate_local_matches:
	input:
		query = "random_rep{rep}.fasta"
	output:
		query = "genomeB_rep{rep}.fasta",
		matches = "local_matches_rep{rep}.fasta"
	params:
		query_seed = get_seed
	shell:      
		"../scripts/simulate_local_matches.sh {wildcards.rep} {min_len} {min_len} {ref_len} {error_rate} {match_count} {params.query_seed}"

