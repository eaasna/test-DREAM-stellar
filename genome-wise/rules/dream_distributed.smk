f = open("split_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\tkmer-size\n")
f.close()

seg_file = str(os.path.dirname(os.path.realpath(config["ref"]))) + "/seg_files.txt"	
rule valik_write_out_ref:
	input:
		config["ref"]
	output: 
		ref_meta = "meta/k{k}_b{b}_fpr{fpr}_l{min_len}_segments.bin"
	params:
		log = "split_valik.time",	
		filenames = {seg_file}
	shell:
		"""
		( /usr/bin/time -a -o {params.log} -f "%e\t%M\t%x\tvalik-split\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}\t{wildcards.k}" \
			{valik} split {input} --verbose -k {wildcards.k} --fpr {wildcards.fpr} \
				--out {output.ref_meta} --error-rate {max_er}  \
				--pattern {wildcards.min_len} -n {wildcards.b} --write-out &> {output}.split.err)
		"""

rule valik_ref_metadata:
	input:
		ref_meta = "meta/k{k}_b{b}_fpr{fpr}_l{min_len}_segments.bin",
	output: 
		ref_meta = "meta/k{k}_b{b}_fpr{fpr}_l{min_len}.bin"
	params:
		log = "split_valik.time",
		filenames = {seg_file}
	shell:
		"""
		( /usr/bin/time -a -o {params.log} -f "%e\t%M\t%x\tvalik-split\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}\t{wildcards.k}" \
			{valik} split {params.filenames} --metagenome --verbose -k {wildcards.k} --fpr {wildcards.fpr} \
				--out {output.ref_meta} --error-rate {max_er}  \
				--pattern {wildcards.min_len} -n {wildcards.b} --write-out &> {output}.split.err)
		"""

f = open("build_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\tkmer-size\tthreads\tminimiser\tcmin\tcmax\tibf-size\n")
f.close()

rule valik_build:
	input:
		ref = config["ref"],
		ref_meta = "meta/k{k}_b{b}_fpr{fpr}_l{min_len}.bin"
	output: 
		temp("/dev/shm/{prefix}/k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}.index")
	params: 
		log = "build_valik.time",
		is_minimiser = "yes" if minimiser_flag == "--fast" else "no"
	threads: workflow.cores
	shell:
		"""
		( /usr/bin/time -a -o {params.log} -f "%e\t%M\t%x\tvalik-build\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}\t{wildcards.k}\t{workflow.cores}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}" \
			{valik} build {minimiser_flag} --threads {threads} --output {output} \
				--ref-meta {input.ref_meta} --kmer-count-min {wildcards.cmin} \
				--kmer-count-max {wildcards.cmax} )
		truncate -s -1 {params.log}
		ls -lh {output} | awk '{{print "\t" $5}}' >> {params.log}
		
		rm /dev/shm/{prefix}/ref_*_*.minimiser
		rm /dev/shm/{prefix}/ref_*_*.header
		"""

f = open("search_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\tkmer-size\tthreads\tminimiser\tcmin\tcmax\terror-rate\trepeat-flag\tcart-max-cap\tmax-carts\trepeat-period\trepeat-length\trepeats\tmatches\n")
f.close()

rule valik_search:
	input:
		ibf = expand("/dev/shm/{pr}/k{{k}}_b{{b}}_fpr{{fpr}}_l{{min_len}}_cmin{{cmin}}_cmax{{cmax}}.index", pr = prefix),
		query = config["query"],
		ref_meta = "meta/k{k}_b{b}_fpr{fpr}_l{min_len}.bin"
	output:
		"k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff"
	threads: workflow.cores
	params:
		log = "search_valik.time",
		is_minimiser = "yes" if minimiser_flag == "--fast" else "no"
	shell:
		"""
		(/usr/bin/time -a -o {params.log} -f \
			"%e\t%M\t%x\tvalik-search\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}\t{wildcards.k}\t{threads}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}\t{wildcards.er}\t{repeat_flag}\t{wildcards.max_cap}\t{wildcards.max_carts}" \
			{valik} search --verbose {repeat_flag} \
				--split-query --cache-thresholds --numMatches {num_matches} --distribute \
				--sortThresh {sort_thresh} --time --index {input.ibf} \
				--ref-meta {input.ref_meta} --query {input.query} \
				--error-rate {wildcards.er} --threads {wildcards.t} \
				--output {output} --cart-max-capacity {wildcards.max_cap} \
				--max-queued-carts {wildcards.max_carts} \
				--repeatPeriod {wildcards.rp} --repeatLength {wildcards.rl} \
				&> {output}.search.err)

		truncate -s -1 {params.log}
		grep "Insufficient" {output}.search.err | wc -l | awk '{{ print "\t" $1}}' >> {params.log}
	
		truncate -s -1 {params.log}
		wc -l {output} | awk '{{ print "\t" $1 "\t"}}' >> {params.log}

		"""

