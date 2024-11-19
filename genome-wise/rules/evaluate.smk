rule stellar_accuracy:
	input:
		search = "stellar_e{er}.gff"
	output:
		temp("evaluation/stellar_e{er}.tsv")
	shell:
		"scripts/evaluation_log.sh {wildcards.er} {input} {output}"

rule stellar_table1:
	input:
		benchmark = expand("benchmarks/stellar_e{er}.txt", er=error_rates),
		evaluation = expand("evaluation/stellar_e{er}.tsv", er=error_rates)
	output:
		"stellar_table1.tsv"
	params:
		repeats = n,	# set as parameters to use in .py
		error_rates = error_rates,
		prefix = "stellar"
	script:
		"../scripts/make_table1.py"

rule dream_accuracy:
	input:
		search = "valik_e{er}_b{b}.gff",
	output:
		temp("evaluation/valik_e{er}_b{b}.tsv")
	shell:
		"scripts/evaluation_log.sh {wildcards.er} {input} {output}"

rule valik_table1:
	input:
                benchmark = expand("benchmarks/valik_e{er}_b{{b}}.txt", er=error_rates),
                evaluation = expand("evaluation/valik_e{er}_b{{b}}.tsv", er=error_rates)
	output:
		"valik_table1_b{b}.tsv"
	params:
		repeats = n,	# set as parameters to use in .py,
		error_rates = error_rates,
		prefix = "valik"
	script:
		"../scripts/make_table1.py"

rule blast_accuracy:
	input:
		search = "blast.tsv",
	output:
		"evaluation/blast.tsv"
	shell:
		"scripts/blast_evaluation_log.sh {input} {output}"

rule blast_table1:
	input:
                benchmark = expand("benchmarks/blast.txt", er=error_rates),
                evaluation = expand("evaluation/blast.tsv", er=error_rates)
	output:
		"blast_table1.tsv"
	params:
		repeats = n	# set as parameters to use in .py
	script:
		"../scripts/make_blast_table1.py"

accuracy_log = "search_valik.accuracy"
f = open(accuracy_log, "a")
f.write("bins\tfpr\tmax-er\tmin-len\tkmer-size\tthreads\tminimiser\tcmin\tcmax\terror-rate\trepeat-flag\tbin-entropy-cutoff\tcart-max-cap\tmax-carts\trepeat-period\trepeat-length\trepeats\tmatches\ttruth-set-matches\ttrue-matches\tmissed\tmin-overlap\ttruth-file\n")
f.close()

rule valik_compare_stellar:
	input:
		truth = "../stellar/" + run_id + "_l{min_len}_e{er}_rp{rp}_rl{rl}.gff",
		ref_meta = "meta/b{b}_fpr{fpr}_l{min_len}.bin",
		test = "b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff"
	output:
		fn = "b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.missed.gff",
		dummy = "b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff.stellar.done" 
	params:
		log = {accuracy_log},
		is_minimiser = "yes" if minimiser_flag == "--fast" else "no"
	threads: workflow.cores
	shell:
		"""
		echo -e "valik-search\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}\tN/A\t{threads}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}\t{wildcards.er}\t{repeat_flag}\t{wildcards.bin_ent}\t{wildcards.max_cap}\t{wildcards.max_carts}" >> {params.log}
		
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
		test = "b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff",
		truth = blast_truth_file
	output:
		fn = "b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.missed.gff",
		dummy = "b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff.blast.done" 
	params:
		log = {accuracy_log},
		is_minimiser = "yes" if minimiser_flag == "--fast" else "no"
	threads: workflow.cores
	shell:
		"""	
		echo -e "valik-search\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}\tN/A\t{threads}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}\t{wildcards.er}\t{repeat_flag}\t{wildcards.bin_ent}\t{wildcards.max_cap}\t{wildcards.max_carts}" >> {params.log}
		
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

rule valik_compare_stellar_kmer:
	input:
		truth = "../stellar/" + run_id + "_l{min_len}_e{er}_rp{rp}_rl{rl}.gff",
		ref_meta = "meta/k{k}_b{b}_fpr{fpr}_l{min_len}.bin",
		test = "k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff"
	output:
		fn = "k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.missed.gff",
		dummy = "k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff.stellar.done" 
	params:
		log = {accuracy_log},
		is_minimiser = "yes" if minimiser_flag == "--fast" else "no"
	threads: workflow.cores
	shell:
		"""	
		echo -e "valik-search\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}\t{wildcards.k}\t{threads}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}\t{wildcards.er}\t{repeat_flag}\t{wildcards.bin_ent}\t{wildcards.max_cap}\t{wildcards.max_carts}" >> {params.log}
		
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

rule valik_compare_blast_kmer:
	input:
		ref_meta = "meta/b{b}_fpr{fpr}_l{min_len}.bin",
		test = "k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff",
		truth = blast_truth_file
	output:
		fn = "k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.missed.gff",
		dummy = "k{k}_b{b}_fpr{fpr}_l{min_len}_cmin{cmin}_cmax{cmax}_e{er}_ent{bin_ent}_cap{max_cap}_carts{max_carts}_t{t}_rp{rp}_rl{rl}.gff.blast.done" 
	params:
		log = {accuracy_log},
		is_minimiser = "yes" if minimiser_flag == "--fast" else "no"
	threads: workflow.cores
	shell:
		"""	
		echo -e "valik-search\t{wildcards.b}\t{wildcards.fpr}\t{max_er}\t{wildcards.min_len}\t{wildcards.k}\t{threads}\t{params.is_minimiser}\t{wildcards.cmin}\t{wildcards.cmax}\t{wildcards.er}\t{repeat_flag}\t{wildcards.bin_ent}\t{wildcards.max_cap}\t{wildcards.max_carts}" >> {params.log}

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
