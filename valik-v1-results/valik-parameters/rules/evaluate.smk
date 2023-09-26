rule match_list:
	input:
		"stellar/bin_{bin}_e{sim_errors}.gff"
	output:
		"matches/bin_{bin}_e{sim_errors}.txt"
	shell:
		"""
		cut -d ";" -f 1 {input} | awk "{{print \$1,\$9}}" > {output}
		"""

rule size_accuracy:
	input:
		expand("matches/bin_{bin}_e{sim_er}.txt", bin = bin_list, sim_er = sim_errors),
		expand("{size}/e{sim_er}_o{o}.out", size = ibf_sizes, sim_er = sim_errors, o = overlap)
	output:
		"search_accuracy.tsv"
	script:
		"../scripts/assess_accuracy.py"
