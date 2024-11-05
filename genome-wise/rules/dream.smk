f = open("split_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\n")
f.close()

rule valik_split_ref:
	input:
		config["ref"]
	output: 
		ref_meta = "meta/b{b}_fpr{fpr}_l{min_len}.bin"
	shell:
		"""
		( /usr/bin/time -a -o split_valik.time -f "%e\t%M\t%x\tvalik-split\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}" {valik} split {input} --verbose --fpr {wildcards.fpr} --out {output.ref_meta} --error-rate {max_er}  --pattern {wildcards.min_len} -n {wildcards.b} )
		"""

f = open("build_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\tthreads\tminimiser\tcmin\tcmax\tibf-size\n")
f.close()

rule valik_build:
	input:
		ref = config["ref"],
		ref_meta = "meta/b{b}_fpr{fpr}_l{min_len}.bin"
	output: 
		temp("/dev/shm/{prefix}/b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}.index")
	params: 
		is_minimiser = "yes" if minimiser_flag == '--fast' else "no"
	threads: workflow.cores
	shell:
		"""
		( /usr/bin/time -a -o build_valik.time -f "%e\t%M\t%x\tvalik-build\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}\t{workflow.cores}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}" {valik} build {minimiser_flag} --threads {threads} --output {output} --ref-meta {input.ref_meta} --kmer-count-min {wildcards.cmin} --kmer-count-max {wildcards.cmax} )
		truncate -s -1 build_valik.time
		ls -lh {output} | awk '{{print "\t" $5}}' >> build_valik.time
		"""

f = open("search_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\tthreads\tminimiser\tcmin\tcmax\terror-rate\trepeat-flag\tbin-entropy-cutoff\tcart-max-cap\tmax-carts\trepeats\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin-overlap\n")
f.close()

rule valik_search:
	input:
		ibf = expand("/dev/shm/{pr}/b{{b}}_fpr{{fpr}}_l{{min_len}}_cmin{{cmin}}_cmax{{cmax}}.index", pr = prefix),
		query = config["query"],
		ref_meta = "meta/b{b}_fpr{fpr}_l{min_len}.bin",
		truth_file = config["truth_file"]
	output:
		"b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}.gff"
	threads: workflow.cores
	params:
		log = "valik_search.time",
		is_minimiser = "yes" if minimiser_flag == '--fast' else "no",
		repeats = "best" if repeat_flag == '--keep-best-repeats' else "none"
	shell:
		"""
		/usr/bin/time -a -o {params.log} -f \
			"%e\t%M\t%x\tvalik-search\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}\t{threads}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}\t{wildcards.er}\t{repeat_flag}\t{wildcards.bin_ent}\t{wildcards.max_cap}\t{wildcards.max_carts}" \
			{valik} search --verbose {repeat_flag} --bin-entropy-cutoff {wildcards.bin_ent} \
				--split-query --cache-thresholds --numMatches {num_matches} \
				--sortThresh {sort_thresh} --time --index {input.ibf} --ref-meta {input.ref_meta} \
				--query {input.query} --error-rate {wildcards.er} --threads {threads} \
				--output {output} --cart-max-capacity {wildcards.max_cap} \
				--max-queued-carts {wildcards.max_carts} 2> {output}.err


		truncate -s -1 {params.log}
		grep "Insufficient" {output}.err | wc -l | awk '{{ print "\t" $1}}' >> {params.log}
	
		truncate -s -1 {params.log}
		wc -l {output} | awk '{{ print "\t" $1 "\t"}}' >> {params.log}

		truncate -s -1 {params.log}
		if [ -s {input.truth_file} ];  && [ -s {output} ]; then
			../../scripts/search_accuracy.sh {input.truth_file} {output} {wildcards.min_len} {min_overlap} {input.ref_meta} tmp.log
			tail -n 1 tmp.log >> {params.log}
			rm tmp.log
		else
			echo -e "N/A\tN/A\tN/A" >> {params.log}
		fi

		truncate -s -1 {params.log}
		echo -e "\t{min_overlap}" >> {params.log}
		"""
