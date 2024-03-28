f = open("valik.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\tParams\n")
f.close()

rule valik_split_ref:
	input:
		"/buffer/ag_abi/evelina/human_dna4.fa"
	output: 
		ref_meta = "meta/ref.bin"
	params: 
		max_er = max(error_rates) 
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-split-ref\t{threads}\tbins={bins}\tmin_len={min_len}\tmax_er={params.max_er}" valik split {input} --verbose --out {output.ref_meta} --error-rate {params.max_er}  --pattern {min_len} -n {bins} )
		"""

rule valik_build:
	input:
		ref = "/buffer/ag_abi/evelina/human_dna4.fa",
		ref_meta = "meta/ref.bin"
	output: 
		temp("/dev/shm/human.index")
	threads: workflow.cores
	benchmark:
		"benchmarks/valik_build.txt"
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-build\t{threads}" valik build {input.ref} --threads {threads} --output {output} --fpr {fpr} --ref-meta {input.ref_meta} )
		truncate -s -1 valik.time
		echo -n "\tibf_size=" >> valik.time
		ls -lh {output} | awk "{{OFS="\\t"}};{{print \$5}}" >> valik.time
		"""

rule valik_search:
	input:
		ibf = "/dev/shm/human.index",
		query = "/buffer/ag_abi/evelina/mouse/dna4.fa",
		ref_meta = "meta/ref.bin"
	output:
		"valik_e{er}.gff"
	threads: workflow.cores
	benchmark:
		"benchmarks/valik_e{er}.txt"
	shell:
		"""
		( timeout 1h /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-search\t{threads}\ter={wildcards.er}" valik search --split-query --verbose --cache-thresholds --numMatches {num_matches} --sortThresh {sort_thresh} --time --index {input.ibf} --ref-meta {input.ref_meta} --query {input.query} --error-rate {wildcards.er} --threads {threads} --output {output} --cart_max_capacity {max_capacity} --max_queued_carts {max_carts} || touch {output} )
		"""

