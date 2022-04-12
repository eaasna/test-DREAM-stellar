rule stellar_accuracy:
	input:
		stellar = "stellar/rep{rep}_e{er}.gff",
		truth = "ground_truth/rep{rep}_e{er}.tsv"
	output:
		"evaluation/rep{rep}_e{er}.tsv"
	params:
		min_overlap = min_overlap
	script:
		"../scripts/evaluate_stellar_search.py"

rule table1:
	input:
                benchmark = expand("benchmarks/stellar_rep{rep}_e{er}.txt", rep=repetitions, er=error_rates),
                evaluation = expand("evaluation/rep{rep}_e{er}.tsv", rep=repetitions, er=error_rates)
	output:
		"table1.tsv"
	params:
		repeats = n,	# set as parameters to use in .py
		error_rates = error_rates
	script:
		"../scripts/make_stellar_table1.py"

