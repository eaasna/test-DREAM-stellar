rule simulate_sequences:
	output:
		ref = "ref_rep{rep}.fasta",
		query = "query/one_line_rep{rep}.fasta"
	params:
		ref_seed = get_seed,
		query_seed = get_seed
	shell:      
		"../scripts/simulate_sequences.sh {wildcards.rep} {ref_len} {query_len} {params.ref_seed} {params.query_seed}"

rule simulate_matches:
	input:
		ref = "ref_rep{rep}.fasta"
	output:
		matches = "local_matches/rep{rep}_e{er}.fastq"
	shell:      
		"../scripts/simulate_local_matches.sh {wildcards.rep} {wildcards.er} {matches} {min_len} {max_len} {ref_len}"

rule insert_matches:
	input:
		query = "query/one_line_rep{rep}.fasta",
		matches = "local_matches/rep{rep}_e{er}.fastq"
	output:     
		query = "query/with_insertions_rep{rep}_e{er}.fasta",
		ground_truth = "ground_truth/rep{rep}_e{er}.tsv"
	params:     
		seed = get_seed
	script:     
		"../scripts/insert_local_matches.py"

