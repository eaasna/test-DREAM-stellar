rule gather_average_runtime:
	input:
		expand("rep{rep}/dream_stellar/bin_{bin}_e{er}.gff", rep = repetitions, bin = bin_list, er = error_rates),	
		expand("rep{rep}/stellar/bin_{bin}_e{er}.gff", rep = repetitions, bin = bin_list, er = error_rates)
	output:
		"table1.tsv"
	script:
		"../scripts/runtime_mean.py"
	
