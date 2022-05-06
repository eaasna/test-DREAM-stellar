rule gather_average_runtime:
	input:
		expand("{b}/dream_stellar/bin_{bin}_e{er}.gff", b = bins, bin = bin_list, er = config["error_rate"]),	
		expand("{b}/stellar/bin_{bin}_e{er}.gff", b = bins, bin = bin_list, er = config["error_rate"])
	output:
		"table1.tsv"
	script:
		"../scripts/runtime_mean.py"
	
