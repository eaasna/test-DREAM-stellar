f = open("valik.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\n")
f.close()

#mutex = "stellar_table1.tsv",
rule valik_split_ref:
	input:
		ref = "ref_rep{rep}.fasta"
	output: 
		ref_meta = "meta/ref_rep{rep}.txt"
	params: 
		max_er = max(error_rates)
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tsplit-ref\t{threads}" valik split {input.ref} --verbose --out {output.ref_meta} --error-rate {params.max_er} --pattern {min_len} -n {bins})
		"""

rule valik_build:
	input:
		ref = "ref_rep{rep}.fasta",
		ref_meta = "meta/ref_rep{rep}.txt"
	output: 
		temp("/dev/shm/rep{rep}_e{er}.index")
	threads: workflow.cores
	benchmark:
		"benchmarks/valik_build_rep{rep}_e{er}.txt"
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tbuild-ibf\t{threads}" valik build --threads {threads} --output {output} --size {size} --ref-meta {input.ref_meta})
		"""

rule valik_search:
	input:
		ibf = "/dev/shm/rep{rep}_e{er}.index",
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
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-search\t{threads}\t{wildcards.er}" valik search --split-query --verbose --cache-thresholds --numMatches {num_matches} --sortThresh {sort_thresh} --time --index {input.ibf} --ref-meta {input.ref_meta} --query {input.query} --error-rate {params.e} --threads {threads} --output {output} --cart-max-capacity {max_capacity} --max-queued-carts {max_carts})
		"""

