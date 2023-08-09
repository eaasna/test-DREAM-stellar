rule simulate_sequences:
	output:
		ref = "ref.fasta",
		query = "query.fasta"
	params:
		ref_seed = get_seed
	shell:      
		"../scripts/simulate_reference.sh {ref_len} {params.ref_seed} {output.ref} {output.query}"

