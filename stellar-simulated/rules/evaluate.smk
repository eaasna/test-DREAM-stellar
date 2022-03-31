min_overlap = config["min_overlap"]
rule stellar_accuracy:
	input:
		stellar = "stellar/{rep}_{er}.gff",
		truth = "ground_truth/{rep}_{er}.tsv"
	output:
		"evaluation/{rep}_{er}.tsv"
	script:
		"../scripts/evaluate_stellar_search.py"

rule table1:
	input:
                benchmark = expand("benchmarks/stellar_{rep}_{er}.txt", rep=repetitions, er=error_rates),
                evaluation = expand("evaluation/{rep}_{er}.tsv", rep=repetitions, er=error_rates)
	output:
		"table1.tsv"
	script:
		"../scripts/make_stellar_table1.py"

