# stellar query sequences have to be in fasta format
rule convert_fastq:
	input:
		"../data/64/reads_e10_150/all.fastq"
	output:
		"../data/64/reads_e10_150/all.fasta"
	shell:
		"sed -n '1~4s/^@/>/p;2~4p' {input} > {output}"

rule stellar:
	input:
		reads = "../data/64/reads_e10_150/all.fasta",
		reference = "../data/64/bins/{bin}.fasta"
	output:
		"stellar/{bin}.gff"
	conda:
		"../envs/stellar.yaml"
	params: 
		e = config["error_rate"],
		l = config["min_length"]
	shell:
		"stellar -e {params.e} -l {params.l} {input.reference} {input.reads} -o {output}"

