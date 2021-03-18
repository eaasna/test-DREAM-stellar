rule raptor_build:
	input:
		expand("../data/1024/bins/{bin}.fasta", bin = bins)
	output:
		"raptor/index.raptor"
	conda:
		"../envs/raptor.yaml"
	threads: 8
	params: 
		k = config["k"],
		win = config["win"],
		size = config["size"]
	shell:
		"raptor build --kmer {params.k} --window {params.win} --size {params.size} --output {output} {input}"
