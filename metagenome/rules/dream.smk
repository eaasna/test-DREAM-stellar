f = open("valik.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

rule valik_split:
	input: 
		fasta = expand("{{b}}/bins/bin_{bin}.fasta", bin = bin_list),
		bin_list = "{b}/bin_paths.txt"
	output:
		"{b}/bin_paths.bin"
	params:
		max_er = max(error_rates)
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-split" valik split {input.bin_list} --metagenome --verbose --out {output} --error-rate {params.max_er} --pattern {min_len} )"""
	
rule valik_build:
	input:
		meta = "{b}/bin_paths.bin"
	output: 
		temp("/dev/shm/{b}.index.ibf")
	threads: workflow.cores
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-build\t{threads}" valik build --ref-meta {input.meta} --threads {threads} --output {output} --size {size} )
		"""

rule valik_search:
	input:
		ibf = "/dev/shm/{b}.index.ibf",
		query = "{b}/queries/e{er}.fastq",
		meta = "{b}/bin_paths.bin"
	output:
		"{b}/valik/e{er}.gff"
	threads: workflow.cores
	params:
		e = get_search_error_rate
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-search\t{threads}" valik search --distribute --time --index {input.ibf} --query {input.query} --error-rate {params.e} --threads {threads} --output {output} --ref-meta {input.meta} )
		"""

