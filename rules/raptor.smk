rule raptor_build:
	input:
		expand("../data/1024/bins/{bin}.fasta", bin = bins)
	output:
		"raptor/index.raptor"
	conda:
		"../envs/raptor.yaml"
	params: 
		k = config["k"],
		win = config["win"],
		size = config["size"]
	shell:
		"raptor build --kmer {params.k} --window {params.win} --size {params.size} --output {output} {input}"

rule raptor_search:
	input:
		index = "raptor/index.raptor",
		reads = "../data/1024/reads_e10_150/{bin}.fastq"
	output:
		"raptor/{bin}.output"
	conda:
		"../envs/raptor.yaml"
	params:
		k = config["k"],
		win = config["win"],
		e = config["nr_errors"]
	shell:
		"raptor search --kmer {params.k} --window {params.win} --error {params.e} --index {input.index} --query {input.reads} --output {output}"	
