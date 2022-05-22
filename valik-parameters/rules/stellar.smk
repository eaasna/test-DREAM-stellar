# stellar query sequences have to be in fasta format
rule convert_fastq:
	input:
		"queries/e{sim_errors}.fastq"
	output:
		temp("queries/e{sim_errors}.fasta")
	shell:
		"sed -n '1~4s/^@/>/p;2~4p' {input} > {output}"

rule stellar:
	input:
		ref = "bins/bin_{bin}.fasta",
		query = "queries/e{sim_errors}.fasta"
	output:
		temp("stellar/bin_{bin}_e{sim_errors}.gff")
<<<<<<< HEAD
	threads: 4
=======
>>>>>>> 4151ee7067984be479aef200d1ec2ca8cbea6513
	conda:
		"../envs/stellar.yaml"
	params:
		er = search_error_rate
	shell:
		"stellar --verbose {input.ref} {input.query} -e {params.er} -l {pattern} -a dna --forward -o {output}"

