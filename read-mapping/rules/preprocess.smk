rule get_reference:
	output:
		temp("dmel-dna5.fasta")
	params:
		full_name = "dmel-all-chromosome-r6.46.fasta"
	shell:      
		"../scripts/get_fly_genome.sh {params.full_name} {output}"

rule make_dna4:
	input: 
		"dmel-dna5.fasta"
	output:
		"dmel.fasta"
	shell:
		"st_dna5todna4 {input} > {output}" 

rule get_reads:
	input:
		"dmel.fasta"
	output:
		reads = "reads_rep{rep}_e{er}_l{len}/dmel.fastq"
	params:
		query_seed = get_seed,
		error_count = get_simulation_error_count
	shell:      
		"""
		../scripts/get_fly_reads.sh {input} {wildcards.rep} {params.query_seed} {params.error_count} {wildcards.er} {wildcards.len} {match_count}
		"""

rule fastq_to_fasta:
	input:
		"reads_rep{rep}_e{er}_l{len}/dmel.fastq"
	output:
		"reads_rep{rep}_e{er}_l{len}/dmel.fasta"
	shell:      
		"sed -n '1~4s/^@/>/p;2~4p' {input} > {output}"
