rule convert_to_fasta:
	input:
		fastq = "{b}/queries/e{er}.fastq"
	output:
		fasta = "{b}/queries/e{er}.fasta"
	benchmark:
		"benchmarks/{b}/stellar/convert_fasta_e{er}.txt"
	shell:
		"sed -n '1~4s/^@/>/p;2~4p' {input} > {output}"

rule stellar_search:
	input:
		ref = "{b}/ref.fasta",
		query = "{b}/queries/e{er}.fasta"
	output:
		"{b}/stellar/e{er}.gff"
	params:
		e = get_search_error_rate
	conda:
		"../envs/stellar.yaml"
	benchmark:
		"benchmarks/{b}/stellar/e{er}.txt"
	shell:
		"stellar --verbose {input.ref} {input.query} -e {params.e} -l {pattern} -a dna -o {output}"
	
