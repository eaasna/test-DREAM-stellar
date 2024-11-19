f = open("split_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\n")
f.close()

rule valik_split_ref:
	input:
		config["ref"]
	output: 
		ref_meta = "meta/b{b}_fpr{fpr}_l{min_len}_e{er}.bin"
	params:
		log = "split_valik.time"
	shell:
		"""
		( /usr/bin/time -a -o {params.log} -f "%e\t%M\t%x\tvalik-split\t{wildcards.b}\t{wildcards.fpr}\t{wildcards.er}\t{wildcards.min_len}" \
			{valik} split {input} --verbose --fpr {wildcards.fpr} --out {output.ref_meta} \
				--error-rate {wildcards.er}  --pattern {wildcards.min_len} -n {wildcards.b} &> {output}.split.err)
		"""

f = open("build_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\tthreads\tminimiser\tcmin\tcmax\tibf-size\n")
f.close()

rule valik_build:
	input:
		ref = config["ref"],
		ref_meta = "meta/b{b}_fpr{fpr}_l{min_len}_e{er}.bin"
	output: 
		temp("/dev/shm/" + prefix + "/b{b}_fpr{fpr}_l{min_len}_e{er}_cmin{cmin}_cmax{cmax}.index")
	params: 
		log = "build_valik.time",
		is_minimiser = "yes" if minimiser_flag == "--fast" else "no"
	threads: workflow.cores
	shell:
		"""
		( /usr/bin/time -a -o {params.log} -f "%e\t%M\t%x\tvalik-build\t{wildcards.b}\t{wildcards.fpr}\t{wildcards.er}\t{wildcards.min_len}\t{workflow.cores}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}" \
			{valik} build {minimiser_flag} --threads {threads} --output {output} \
				--ref-meta {input.ref_meta} --kmer-count-min {wildcards.cmin} \
				--kmer-count-max {wildcards.cmax} )
		truncate -s -1 {params.log}
		ls -lh {output} | awk '{{print "\t" $5}}' >> {params.log}

		rm /dev/shm/{prefix}/ref_concat.*.minimiser
		rm /dev/shm/{prefix}/ref_concat.*.header
		"""

f = open("search_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\tthreads\tminimiser\tcmin\tcmax\terror-rate\trepeat-flag\tbin-entropy-cutoff\tcart-max-cap\tmax-carts\trepeat-period\trepeat-length\trepeats\tmatches\n")
f.close()

rule valik_search:
	input:
		ibf = expand("/dev/shm/" + prefix + "/b{b}_fpr{fpr}_l{min_len}_e{er}_cmin{cmin}_cmax{cmax}.index"),
		query = config["query"],
		ref_meta = "meta/b{b}_fpr{fpr}_l{min_len}.bin"
	output:
		"b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff"
	threads: workflow.cores
	params:
		log = "search_valik.time",
		is_minimiser = "yes" if minimiser_flag == "--fast" else "no"
	shell:
		"""
		(/usr/bin/time -a -o {params.log} -f \
			"%e\t%M\t%x\tvalik-search\t{wildcards.b}\t{wildcards.fpr}\t{wildcards.er}\t{wildcards.min_len}\t{threads}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}\t{wildcards.er}\t{repeat_flag}\t{wildcards.bin_ent}\t{wildcards.max_cap}\t{wildcards.max_carts}\t{wildcards.rp}\t{wildcards.rl}" \
			{valik} search --verbose {repeat_flag} --bin-entropy-cutoff {wildcards.bin_ent} \
				--split-query --cache-thresholds --numMatches {num_matches} \
				--sortThresh {sort_thresh} --time --index {input.ibf} --ref-meta {input.ref_meta} \
				--query {input.query} --error-rate {wildcards.er} --threads {wildcards.t} \
				--output {output} --cart-max-capacity {wildcards.max_cap} \
				--max-queued-carts {wildcards.max_carts} \
				--repeatPeriod {wildcards.rp} --repeatLength {wildcards.rl} \
				&> {output}.search.err)

		truncate -s -1 {params.log}
		grep "Insufficient" {output}.search.err | wc -l | awk '{{ print "\t" $1}}' >> {params.log}
	
		truncate -s -1 {params.log}
		wc -l {output} | awk '{{ print "\t" $1}}' >> {params.log}

		"""

