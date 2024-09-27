f = open("valik.time", "a")
f.write("#### PARAMS ####\n")
for par in config:
	f.write(par + '\t' + str(config[par]) + '\n')
f.write("#### LOG ####\n")
f.write("Time\tMemory\tExitcode\tCommand\tThreads\tParams\n")
f.close()

rule valik_split_ref:
	input:
		mutex = "stellar_table1.tsv",
		ref = "ref_rep{rep}.fasta"
	output: 
		ref_meta = "meta/ref_rep{rep}_e{er}.bin"
	params: 
		max_er = max(error_rates)
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tsplit-ref\t{threads}\tbins={bins}\tmax_er={wildcards.er}" valik split {input.ref} --verbose --out {output.ref_meta} --error-rate {wildcards.er} --pattern {min_len} -n {bins} --fpr {fpr})
		"""

rule valik_build:
	input:
		ref = "ref_rep{rep}.fasta",
		ref_meta = "meta/ref_rep{rep}_e{er}.bin"
	output: 
		temp("/dev/shm/rep{rep}_e{er}.index")
	threads: workflow.cores
	benchmark:
		"benchmarks/valik_build_rep{rep}_e{er}.txt"
	shell:
		"""
		( /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tbuild-ibf\t{threads}\tfpr={fpr}\ter={wildcards.er}" valik build --threads {threads} --output {output} --ref-meta {input.ref_meta})
		truncate -s -1 valik.time
		echo -n "\tibf_size=" >> valik.time
		ls -lh {output} | awk "{{OFS="\\t"}};{{print \$5 }}" >> valik.time
		"""

rule valik_search:
	input:
		ibf = "/dev/shm/rep{rep}_e{er}.index",
		query = "query/rep{rep}_e{er}.fasta",
		ref_meta = "meta/ref_rep{rep}_e{er}.bin"
	output:
		"valik/rep{rep}_e{er}.gff"
	threads: workflow.cores
	benchmark: 
		"benchmarks/valik_rep{rep}_e{er}.txt"
	shell:
		"""
		( timeout 12h /usr/bin/time -a -o valik.time -f "%e\t%M\t%x\tvalik-search\t{threads}\ter={wildcards.er}" valik search --split-query --verbose --cache-thresholds --numMatches {num_matches} --sortThresh {sort_thresh} --time --index {input.ibf} --ref-meta {input.ref_meta} --query {input.query} --error-rate {wildcards.er} --threads {threads} --output {output} --cart-max-capacity {max_capacity} --max-queued-carts {max_carts} || touch {output} )
		"""

