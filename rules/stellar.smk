# stellar query sequences have to be in fasta format
rule convert_fastq:
	input:
		"../data/64/reads_e{rer}_150/{bin}.fastq"
	output:
		"../data/64/reads_e{rer}_150/{bin}.fasta"
	shell:
		"sed -n '1~4s/^@/>/p;2~4p' {input} > {output}"

rule stellar:
	input:
		reads = "../data/64/reads_e{rer}_150/{bin}.fasta",
		reference = "../data/64/all_bins.fasta"
	output:
		"../data/64/output_e{rer}/stellar/{bin}_{l}p_{e}e.gff"
	params:
		er = 2 / 70
	conda:
		"../envs/stellar.yaml"
	shell:
		"stellar -e {params.er} -l {wildcards.l} {input.reference} {input.reads} -o {output}"
		#"stellar -l {wildcards.l} {input.reference} {input.reads} -o {output}"

rule remove_metadata:
	input:
		"../data/64/output_e{rer}/stellar/{bin}_{l}p_{e}e.gff"
	output:
		"../data/64/output_e{rer}/stellar/{bin}_{l}p_{e}e_sed.gff"
	shell:
		"sed 's/;.*//' {input} > {output}"
		
