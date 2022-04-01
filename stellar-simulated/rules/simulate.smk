import random

# simulation needs unique seeds otherwise the same sequence is simulated
def get_seed(wildcards):
	return random.randint(0, 1e6)
	
rule simulate:
	output:
		ref = "ref_{rep}.fasta",
		query = "query/one_line_{rep}.fasta",
		matches = expand("local_matches/{{rep}}_{er}.fastq", er=error_rates)
	params:
		ref_seed = get_seed,
		query_seed = get_seed
	shell:
		"./scripts/simulate.sh {wildcards.rep} {params.ref_seed} {params.query_seed}"

rule insert_matches:
	input:
		ref = "ref_{rep}.fasta",
		query = "query/one_line_{rep}.fasta",
		matches = "local_matches/{rep}_{er}.fastq"
	output:
		query = "query/with_insertions_{rep}_{er}.fasta",
		ground_truth = "ground_truth/{rep}_{er}.tsv"
	params:
		seed = get_seed
	script:
		"../scripts/insert_local_matches.py"

