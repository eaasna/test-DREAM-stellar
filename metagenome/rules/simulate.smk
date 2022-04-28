import random
# simulation needs unique seeds otherwise the same sequence is simulated
def get_seed(wildcards):
        return random.randint(0, 1e6)

def get_error_count(wildcards):
	error_count = round(int(match_len) * float(wildcards.er))
        return error_count

rule simulate_database:
	output:
		ref = expand("rep{{rep}}/bins/bin_{bin}.fasta", bin = bin_list)
	params:
		ref_seed = get_seed
	shell:      
		"../scripts/simulate_database.sh {wildcards.rep} {ref_len} {params.ref_seed} {bins} {ht}"

rule simulate_reads:
	input:
		ref = expand("rep{{rep}}/bins/bin_{bin}.fasta", bin = bin_list)
	output:
		matches = "rep{rep}/queries/e{er}.fastq"
	params: 
		errors = get_error_count
	shell:      
		"../scripts/simulate_reads.sh {wildcards.rep} {bins} {ht} {params.errors} {wildcards.er} {match_len} {matches}"

