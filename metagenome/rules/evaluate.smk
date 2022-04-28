rule gather_average_runtime:
	input:
		expand("rep{rep}/dream_stellar/seg{bin}_e{er}.gff", rep = repetitions, bin = bin_list, er = error_rates),	
		expand("rep{rep}/stellar/e{er}.gff", rep = repetitions, er = error_rates)
	output:
		"table1.tsv"
	script:
		"../scripts/runtime_mean.py"
	
