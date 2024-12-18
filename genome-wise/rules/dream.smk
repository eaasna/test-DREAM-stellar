f = open(dream_out + "/split_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\n")
f.close()

rule valik_split_ref:
	input:
		dir_path(config["ref"]) + "dna4.fasta"
	output: 
		ref_meta = dream_out + "/meta/b{b}_fpr{fpr}_l{min_len}_e{er}.bin"
	params:
		log = "split_valik.time",
		er_rate = get_error_rate
	shell:
		"""
		( /usr/bin/time -a -o {params.log} -f "%e\t%M\t%x\tvalik-split\t{wildcards.b}\t{wildcards.fpr}\t{params.er_rate}\t{wildcards.min_len}" \
			{valik} split {input} --verbose --fpr {wildcards.fpr} --out {output.ref_meta} --kmer 18 \
				--error-rate {params.er_rate}  --pattern {wildcards.min_len} -n {wildcards.b} &> {output}.split.err)
		"""
			#{valik} split {input} --verbose --fpr {wildcards.fpr} --out {output.ref_meta} \

f = open(dream_out + "/build_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\tthreads\tminimiser\tcmin\tcmax\tibf-size\n")
f.close()

rule valik_build:
	input:
		ref = dir_path(config["ref"]) + "dna4.fasta",
		ref_meta = dream_out + "/meta/b{b}_fpr{fpr}_l{min_len}_e{er}.bin"
	output: 
		temp("/dev/shm/" + dream_out + "/b{b}_fpr{fpr}_l{min_len}_e{er}_cmin{cmin}_cmax{cmax}.index")
	params: 
		log = "build_valik.time",
		is_minimiser = "yes" if minimiser_flag == "--fast" else "no",
		er_rate = get_error_rate
	threads: workflow.cores
	shell:
		"""
		( /usr/bin/time -a -o {params.log} -f "%e\t%M\t%x\tvalik-build\t{wildcards.b}\t{wildcards.fpr}\t{params.er_rate}\t{wildcards.min_len}\t{workflow.cores}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}" \
			{valik} build {minimiser_flag} --threads {threads} --output {output} \
				--ref-meta {input.ref_meta} --kmer-count-min {wildcards.cmin} \
				--kmer-count-max {wildcards.cmax} 2> {output}.err)
		truncate -s -1 {params.log}
		ls -lh {output} | awk '{{print "\t" $5}}' >> {params.log}

		rm /dev/shm/{dream_out}/dna4.*.minimiser
		rm /dev/shm/{dream_out}/dna4.*.header
		"""

f = open(dream_out + "/search_valik.time", "a")
f.write("time\tmem\terror-code\tcommand\tbins\tfpr\tmax-er\tmin-len\tthreads\tminimiser\tcmin\tcmax\terror-rate\trepeat-flag\tbin-entropy-cutoff\tcart-max-cap\tmax-carts\trepeat-period\trepeat-length\trepeats\tmatches\n")
f.close()


rule valik_search:
	input:
		ibf = "/dev/shm/" + dream_out + "/b{b}_fpr{fpr}_l{min_len}_e{er}_cmin{cmin}_cmax{cmax}.index",
		query = dir_path(config["query"]) + "dna4.fasta",
		ref_meta = dream_out + "/meta/b{b}_fpr{fpr}_l{min_len}_e{er}.bin"
	output:
		dream_out + "/b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff"
	threads: search_threads
	params:
		log = dream_out + "/search_valik.time",
		is_minimiser = "yes" if minimiser_flag == "--fast" else "no",
		er_rate = get_error_rate
	shell:
		"""
		(/usr/bin/time -a -o {params.log} -f \
			"%e\t%M\t%x\tvalik-search\t{wildcards.b}\t{wildcards.fpr}\t{params.er_rate}\t{wildcards.min_len}\t{threads}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}\t{wildcards.er}\t{repeat_flag}\t{wildcards.bin_ent}\t{wildcards.max_cap}\t{wildcards.max_carts}\t{wildcards.rp}\t{wildcards.rl}" \
			{valik} search --verbose {repeat_flag} --bin-entropy-cutoff {wildcards.bin_ent} \
			 	--split-query --cache-thresholds --numMatches {num_matches} \
				--sortThresh {sort_thresh} --time --index {input.ibf} --ref-meta {input.ref_meta} \
				--query {input.query} --error-rate {params.er_rate} --threads {wildcards.t} \
				--output {output} --cart-max-capacity {wildcards.max_cap} \
				--max-queued-carts {wildcards.max_carts} \
				--repeatPeriod {wildcards.rp} --repeatLength {wildcards.rl} \
				&> {output}.search.err)

		truncate -s -1 {params.log}
		# grep fails in bash strict mode if no matches found
		{{ grep Insufficient {output}.search.err || test $? = 1; }} | wc -l | awk '{{ print "\t" $1}}' >> {params.log}

		truncate -s -1 {params.log}
		wc -l {output} | awk '{{ print "\t" $1}}' >> {params.log}
		"""

rule valik_compare_blast:
	input:
		ref_meta = dream_out + "/meta/b" + str(bin_list[0]) + "_fpr" + str(fpr_list[0]) + "_l" + str(min_lens[0]) + "_e" + str(errors[0]) + ".bin",
		test_files = expand(dream_out + "/b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff", b = bin_list, fpr = fpr_list, min_len = min_lens, cmin = cmin_list, cmax = cmax_list, er = errors, bin_ent = bin_entropy_cutoffs, max_cap = cart_max_capacity, max_carts = max_queued_carts, t = search_threads, rp = repeat_periods, rl = repeat_lengths),
		truth_files = expand(blast_out + "/" + run_id + "_e{ev}_k{k}.bed", ev = evalues, k = blast_kmer_lengths)
	output:
		"valik.blast.accuracy"
	threads:
		workflow.cores
	params:
		min_len = min(min_lens),
		min_overlap = 10
	shell:
		"""
		echo -e "test-file\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin-overlap\ttruth-file" > {output}
		for test in {input.test_files}
		do
			for truth in {input.truth_files}
			do
			
			match_count=`wc -l $test | awk '{{print $1}}'`
			echo -e "$test\t$match_count\t" >> {output}
			
			truncate -s -1 {output}
			../scripts/search_accuracy.sh $truth $test {params.min_len} {params.min_overlap} {input.ref_meta} tmp.log
			tail -n 1 tmp.log >> {output}
			rm tmp.log
	
			truncate -s -1 {output}
			echo -e "\t{params.min_overlap}\t$truth" >> {output}
			done
		done
		"""

rule valik_compare_stellar:
	input:
		ref_meta = dream_out + "/meta/b" + str(bin_list[0]) + "_fpr" + str(fpr_list[0]) + "_l" + str(min_lens[0]) + "_e" + str(errors[0]) + ".bin",
		test_files = expand(dream_out + "/b{b}_fpr{fpr}_l{{min_len}}_cmin{cmin}_cmax{cmax}_e{{er}}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff", b = bin_list, fpr = fpr_list, cmin = cmin_list, cmax = cmax_list, bin_ent = bin_entropy_cutoffs, max_cap = cart_max_capacity, max_carts = max_queued_carts, t = search_threads, rp = repeat_periods, rl = repeat_lengths),
		truth_file = stellar_out + "/" + run_id + "_l{min_len}_e{er}_rp" + str(repeat_periods[0]) + "_rl" + str(repeat_lengths[0]) + ".gff"
	output:
		temp(dream_out + "/valik.accuracy.l{min_len}.e{er}")
	threads:
		workflow.cores
	params:
		min_len = min(min_lens),
		min_overlap = 10,
	shell:
		"""
		echo -e "test-file\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin-overlap\ttruth-file" > {output}
		
		for test in {input.test_files}
		do
			match_count=`wc -l $test | awk '{{print $1}}'`
			echo -e "$test\t$match_count\t" >> {output}
			
			truncate -s -1 {output}
			../scripts/search_accuracy.sh {input.truth_file} $test {params.min_len} {params.min_overlap} {input.ref_meta} tmp.log
			tail -n 1 tmp.log >> {output}
			rm tmp.log
	
			truncate -s -1 {output}
			echo -e "\t{params.min_overlap}\t{input.truth_file}" >> {output}
		done
		"""

rule valik_gather_stellar_accuracy:
	input:
		expand(dream_out + "/valik.accuracy.l{min_len}.e{er}", min_len = min_lens, er = errors)
	output:
		"valik.stellar.accuracy"
	threads: 1
	shell:
		"cat {input} > {output}"

