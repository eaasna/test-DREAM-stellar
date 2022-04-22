import random
# simulation needs unique seeds otherwise the same sequence is simulated
def get_seed(wildcards):
        return random.randint(0, 1e6)

rule simulate_reference:
	output:
		ref = "ref_rep{rep}.fasta"
	params:
		ref_seed = get_seed,
	shell:      
		"../scripts/simulate_reference.sh {wildcards.rep} {ref_len} {params.ref_seed}"

rule simulate_matches:
	input:
		ref = "ref_rep{rep}.fasta"
	output:
		matches = "queries/rep{rep}_e{er}.fastq"
	shell:      
		"../scripts/simulate_local_matches.sh {wildcards.rep} {wildcards.er} {matches} {min_len} {max_len}"

