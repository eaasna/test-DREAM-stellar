f = open("valik.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

rule valik_split_ref:
	input:
		"genomeA_rep{rep}.fasta"
	output: 
		ref_meta = "meta/ref_rep{rep}.txt"
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-split-ref\t{threads}" valik split {input} --out {output.ref_meta} --split-index --overlap {min_len} -n {bins} )
		"""

rule valik_split_query:
	input:
		"genomeB_rep{rep}.fasta"
	output: 
		query_meta = "meta/query_rep{rep}.txt",
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-split-query\t{threads}" valik split {input} --out {output.query_meta} --overlap {min_len} -n {bins} )
		"""

rule valik_build:
	input:
		ref = "genomeA_rep{rep}.fasta",
		ref_meta = "meta/ref_rep{rep}.txt"
	output: 
		temp("/dev/shm/rep{rep}.index")
	threads: 16
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-build\t{threads}" valik build {input.ref} --threads {threads} --window {w} --kmer {k} --output {output} --size {size} --ref-meta {input.ref_meta} )
		"""

rule valik_search:
	input:
		ibf = "/dev/shm/rep{rep}.index",
		query = "genomeB_rep{rep}.fasta",
		query_meta = "meta/query_rep{rep}.txt",
		ref_meta = "meta/ref_rep{rep}.txt"
	output:
		"valik/rep{rep}.gff"
	threads: 16
	params:
		e = get_search_error_rate
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-search\t{threads}" valik search --time --index {input.ibf} --ref-meta {input.ref_meta} --query-meta {input.query_meta} --query {input.query} --error-rate {params.e} --pattern {min_len} --overlap {overlap} --threads {threads} --output {output} --cart_max_capacity {cart_capacity} --max_queued_carts {queued_carts} )
		"""

