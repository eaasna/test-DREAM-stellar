f = open("valik.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

rule valik_build:
	input:
		fasta = expand("{{b}}/bins/bin_{bin}.fasta", bin = bin_list),
		bin_list = "{b}/bin_paths.txt"
	output: 
		temp("/dev/shm/{b}.index.ibf")
	threads: 16
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-build\t{threads}" valik build {input.bin_list} --threads {threads} --window {w} --kmer {k} --output {output} --size {size} )
		"""

rule valik_search:
	input:
		ibf = "/dev/shm/{b}.index.ibf",
		query = "{b}/queries/e{er}.fastq",
	output:
		"{b}/valik/e{er}.gff"
	threads: 16
	params:
		e = get_search_error_rate
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-search\t{threads}" valik search --distribute --time --index {input.ibf} --query {input.query} --error-rate {params.e} --pattern {min_len} --overlap {overlap} --threads {threads} --output {output} --cart_max_capacity {cart_capacity} --max_queued_carts {queued_carts} )
		"""

