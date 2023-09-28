rule simulate_input_sequences:
	output:
		ref = "genomeA_rep{rep}.fasta",
		query = "genomeB_rep{rep}.fasta"
	params:
		ref_seed = get_seed,
		query_seed = get_seed
	shell:      
		"../scripts/simulate_sequences.sh {wildcards.rep} {ref_len} {params.ref_seed} {params.query_seed}"

