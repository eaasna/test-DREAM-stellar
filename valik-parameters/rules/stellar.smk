# stellar query sequences have to be in fasta format
rule convert_fastq:
	input:
		"queries/e{er}.fastq"
	output:
		temp("queries/e{er}.fasta")
	shell:
		"sed -n '1~4s/^@/>/p;2~4p' {input} > {output}"

rule stellar:
	input:
		ref = "bins/bin_{bin}.fasta",
		query = "queries/e{er}.fasta"
	output:
		temp("stellar/bin_{bin}_e{er}.gff")
	params:
		e = get_search_error_rate
	threads: 4
	conda:
		"../envs/stellar.yaml"
	shell:
		"stellar --verbose {input.ref} {input.query} -e {params.e} -l {pattern} -a dna --forward -o {output}"

