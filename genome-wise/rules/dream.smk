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
		ref_meta = "meta/ref_b{b}.bin"
	params: 
		max_er = max(error_rates) 
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-split-ref\t{threads}\tbins={wildcards.b}\tmin_len={min_len}\tmax_er={params.max_er}" valik split {input} --verbose --fpr {fpr} --out {output.ref_meta} --error-rate {params.max_er}  --pattern {min_len} -n {wildcards.b} )
		"""

rule valik_build:
	input:
		ref = "/buffer/ag_abi/evelina/human_dna4.fa",
		ref_meta = "meta/ref_b{b}.bin"
	output: 
		temp("/dev/shm/human_b{b}.index")
	threads: workflow.cores
	benchmark:
		"benchmarks/valik_build_b{b}.txt"
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-build\t{threads}\tfpr={fpr}\bins={wildcards.b}" valik build --threads {threads} --output {output} --ref-meta {input.ref_meta} )
		truncate -s -1 valik.time
		echo -n "\tibf_size=" >> valik.time
		ls -lh {output} | awk "{{OFS="\\t"}};{{print \$5}}" >> valik.time
		"""

rule valik_search:
	input:
		ibf = "/dev/shm/human_b{b}.index",
		query = "/buffer/ag_abi/evelina/mouse/dna4.fa",
		ref_meta = "meta/ref_b{b}.bin"
	output:
		"valik_e{er}_b{b}.gff"
	threads: workflow.cores
	benchmark:
		"benchmarks/valik_e{er}_b{b}.txt"
	shell:
		"""
		( timeout 12h /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-search\t{threads}\tbins={wildcards.b}\ter={wildcards.er}" valik search --split-query --verbose --cache-thresholds --numMatches {num_matches} --sortThresh {sort_thresh} --time --index {input.ibf} --ref-meta {input.ref_meta} --query {input.query} --error-rate {wildcards.er} --threads {threads} --output {output} --cart-max-capacity {max_capacity} --max-queued-carts {max_carts} || touch {output} )
		"""

