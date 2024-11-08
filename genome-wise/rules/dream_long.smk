f = open("split_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\tkmer-size\n")
f.close()


rule valik_split_ref:
	input:
		config["ref"]
	output: 
		ref_meta = "meta/k{k}_b{b}_fpr{fpr}_l{min_len}.bin"
	params:
		log = "split_valik.time"
	shell:
		"""
		( /usr/bin/time -a -o {params.log} -f "%e\t%M\t%x\tvalik-split\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}\t{wildcards.k}" \
			{valik} split {input} --verbose -k {wildcards.k} --fpr {wildcards.fpr} \
				--out {output.ref_meta} --error-rate {max_er}  \
				--pattern {wildcards.min_len} -n {wildcards.b} &> {output}.split.err)
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
		"""

f = open("search_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\tkmer-size\tthreads\tminimiser\tcmin\tcmax\terror-rate\trepeat-flag\tbin-entropy-cutoff\tcart-max-cap\tmax-carts\trepeat-period\trepeat-length\trepeats\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin-overlap\ttruth-file\n")
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
			"%e\t%M\t%x\tvalik-search\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}\t{k}\t{threads}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}\t{wildcards.er}\t{repeat_flag}\t{wildcards.bin_ent}\t{wildcards.max_cap}\t{wildcards.max_carts}" \
			{valik} search --verbose {repeat_flag} --bin-entropy-cutoff {wildcards.bin_ent} \
				--split-query --cache-thresholds --numMatches {num_matches} \
				--sortThresh {sort_thresh} --time --index {input.ibf} --ref-meta {input.ref_meta} \
				--query {input.query} --error-rate {wildcards.er} --threads {wildcards.t} \
				--output {output} --cart-max-capacity {wildcards.max_cap} \
				--max-queued-carts {wildcards.max_carts} \
				--repeatPeriod {wildcards.rp} --repeatLength {wildcards.rl} \
				&> {output}.search.err)

		truncate -s -1 {params.log}
		grep "Insufficient" {output}.err | wc -l | awk '{{ print "\t" $1}}' >> {params.log}
	
		truncate -s -1 {params.log}
		wc -l {output} | awk '{{ print "\t" $1 "\t"}}' >> {params.log}

		"""

rule valik_compare_stellar:
	input:
		truth = "../stellar/" + run_id + "_l{min_len}_e{er}_rp{rp}_rl{rl}.gff",
		ref_meta = "meta/k{k}_b{b}_fpr{fpr}_l{min_len}.bin",
		test = "k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff"
	output:
		fn = "k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.missed.gff",
		dummy = "k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff.stellar.done" 
	params:
		log = "search_valik.time"
	shell:
		"""	
		truncate -s -1 {params.log}
		if [ -s {input.truth}  -a  -s {input.test} ]; then
			../../scripts/search_accuracy.sh {input.truth} {input.test} {wildcards.min_len} {min_overlap} {input.ref_meta} tmp.log
			tail -n 1 tmp.log >> {params.log}
			rm tmp.log
		else
			echo -e "N/A\tN/A\tN/A" >> {params.log}
		fi

		truncate -s -1 {params.log}
		echo -e "\t{min_overlap}\t{input.truth}" >> {params.log}
		
		touch {output.dummy}
		"""

def blast_truth_file(wildcards):
	errors = round(int(wildcards.min_len) * float(wildcards.er))
	for k in range(51, 11, -1):
		if ((int(wildcards.min_len) - k + 1 - errors * k ) > 2):
			return "../blast/" + run_id + "_e" + str(comparison_evalue) + "_k" + str(k) + ".txt" 

rule valik_compare_blast:
	input:
		ref_meta = "meta/b{b}_fpr{fpr}_l{min_len}.bin",
		test = "k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff",
		truth = blast_truth_file
	output:
		fn = "k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.missed.gff",
		dummy = "k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff.blast.done" 
	params:
		log = "search_valik.time"
	shell:
		"""	
		truncate -s -1 {params.log}
		if [ -s {input.truth}  -a  -s {input.test} ]; then
			../../scripts/search_accuracy.sh {input.truth} {input.test} {wildcards.min_len} {min_overlap} {input.ref_meta} tmp.log
			tail -n 1 tmp.log >> {params.log}
			rm tmp.log
		else
			echo -e "N/A\tN/A\tN/A" >> {params.log}
		fi

		truncate -s -1 {params.log}
		echo -e "\t{min_overlap}\t{input.truth}" >> {params.log}
		
		touch {output.dummy}
		"""
