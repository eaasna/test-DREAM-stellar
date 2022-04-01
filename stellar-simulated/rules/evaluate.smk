min_overlap = config["min_overlap"]
rule stellar_accuracy:
	input:
		stellar = "stellar/rep{rep}_e{er}.gff",
		truth = "ground_truth/rep{rep}_e{er}.tsv"
	output:
		"evaluation/rep{rep}_e{er}.tsv"
	script:
		"../scripts/evaluate_stellar_search.py"

rule table1:
	input:
                benchmark = expand("benchmarks/stellar_rep{rep}_e{er}.txt", rep=repetitions, er=error_rates),
                evaluation = expand("evaluation/rep{rep}_e{er}.tsv", rep=repetitions, er=error_rates)
	output:
		"table1.tsv"
	script:
		"../scripts/make_stellar_table1.py"

