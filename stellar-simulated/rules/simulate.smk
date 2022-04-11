import random

ref_len = config["reference_length"]
query_len = config["query_length"]
matches = config["match_count"]

# simulation needs unique seeds otherwise the same sequence is simulated
def get_seed(wildcards):
	return random.randint(0, 1e6)
	
rule simulate:
	output:
		ref = "ref_rep{rep}.fasta",
		query = "query/one_line_rep{rep}.fasta",
		matches = expand("local_matches/rep{{rep}}_e{er}.fastq", er=error_rates)
	params:
		ref_seed = get_seed,
		query_seed = get_seed
	shell:
		"../scripts/simulate.sh {wildcards.rep} {ref_len} {query_len} {params.ref_seed} {params.query_seed} {matches}"

rule insert_matches:
	input:
		ref = "ref_rep{rep}.fasta",
		query = "query/one_line_rep{rep}.fasta",
		matches = "local_matches/rep{rep}_e{er}.fastq"
	output:
		query = "query/with_insertions_rep{rep}_e{er}.fasta",
		ground_truth = "ground_truth/rep{rep}_e{er}.tsv"
	params:
		seed = get_seed
	script:
		"../scripts/insert_local_matches.py"

