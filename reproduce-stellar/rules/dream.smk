f = open("valik.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

rule valik_split_ref:
	input:
		"ref_rep{rep}.fasta"
	output: 
		ref_meta = "meta/ref_rep{rep}.txt"
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\t%C\t{threads}" valik split {input} --out {output.ref_meta} --split-index --overlap {min_len} -n {bins})
		"""

rule valik_split_query:
	input:
		"query/rep{rep}_e{er}.fasta"
	output: 
		query_meta = "meta/query_rep{rep}_e{er}.txt",
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\t%C\t{threads}" valik split {input} --out {output.query_meta} --overlap {min_len} -n {query_seg_count})
		"""

rule valik_build:
	input:
		ref = "ref_rep{rep}.fasta",
		ref_meta = "meta/ref_rep{rep}.txt"
	output: 
		"rep{rep}_e{er}.index"
	threads: workflow.cores
	params: 
		w = get_max_w,
		k = get_k
	benchmark:
		"benchmarks/valik_build_rep{rep}_e{er}.txt"
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\t%C\t{threads}" valik build {input.ref} --threads {threads} --window {params.w} --kmer {params.k} --output {output} --size {size} --ref-meta {input.ref_meta})
		"""

rule valik_search:
	input:
		ibf = "rep{rep}_e{er}.index",
		query = "query/rep{rep}_e{er}.fasta",
		query_meta = "meta/query_rep{rep}_e{er}.txt",
		ref_meta = "meta/ref_rep{rep}.txt"
	output:
		"valik/rep{rep}_e{er}.gff"
	threads: workflow.cores
	params:
		e = get_search_error_rate
	benchmark: 
		"benchmarks/valik_rep{rep}_e{er}.txt"
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\t%C\t{threads}" valik search --time --index {input.ibf} --ref-meta {input.ref_meta} --query-meta {input.query_meta} --query {input.query} --error-rate {params.e} --pattern {min_len} --overlap {overlap} --threads {threads} --output {output} --cart_max_capacity {max_capacity} --max_queued_carts {max_carts})
		"""

