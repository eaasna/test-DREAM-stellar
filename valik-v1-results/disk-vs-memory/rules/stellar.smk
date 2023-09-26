rule convert_to_fasta:
	input:
		fastq = "queries/e{er}.fastq"
	output:
		fasta = "queries/e{er}.fasta"
	shell:
		"sed -n '1~4s/^@/>/p;2~4p' {input} > {output}"

rule stellar_search:
	input:
		ref = "ref.fasta",
		query = "queries/e{er}.fasta"
	output:
		"stellar/e{er}.gff"
	params:
		e = get_search_error_rate
	conda:
		"../envs/stellar.yaml"
	shell:
		"stellar --verbose {input.ref} {input.query} -e {params.e} -l {pattern} -a dna -o {output}"
	
