# stellar query sequences have to be in fasta format
rule convert_fastq:
	input:
		"../data/1024/reads_e10_150/all.fastq"
	output:
		"../data/1024/reads/all.fasta"
	shell:
		"sed -n '1~4s/^@/>/p;2~4p' {input} > {output}"

rule stellar:
	input:
		reads = "../data/1024/reads/all.fasta",
		reference = "../data/1024/bins/{bin}.fasta"
	output:
		"stellar/{bin}.gff"
	conda:
		"/envs/stellar.yaml"
	threads: 8
	params: 
		e = config["e"],
	shell:
		"stellar -e {params.e} {input.reference} {input.reads} -o {output}"

