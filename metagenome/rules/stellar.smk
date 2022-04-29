rule convert_to_fasta:
	input:
		fastq = "rep{rep}/queries/e{er}.fastq"
	output:
		fasta = "rep{rep}/queries/e{er}.fasta"
	benchmark:
		"benchmarks/rep{rep}/stellar/convert_fasta_e{er}.txt"
	shell:
		"sed -n '1~4s/^@/>/p;2~4p' {input} > {output}"

rule stellar_search:
	input:
		ref = "rep{rep}/bins/bin_{bin}.fasta",
		query = "rep{rep}/queries/e{er}.fasta"
	output:
		"rep{rep}/stellar/bin_{bin}_e{er}.gff"
	params:
		e = get_error_rate
	conda:
		"../envs/stellar.yaml"
	benchmark:
		"benchmarks/rep{rep}/stellar/bin_{bin}_e{er}.txt"
	shell:
		"stellar --verbose {input.ref} {input.query} -e {params.e} -l {pattern} -a dna -o {output}"
	
