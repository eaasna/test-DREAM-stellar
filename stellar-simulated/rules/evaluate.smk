rule benchmark_average:
	input:
		expand("benchmarks/stellar_{er}.txt", er=error_rates)
	output:
		avg = "benchmarks/stellar_avg.tsv"
	script:
		"../scripts/run_time_average.py"

min_overlap = config["min_overlap"]
rule stellar_accuracy:
	input:
		stellar = "stellar/{er}.gff",
		truth = "ground_truth/{er}.tsv"
	output:
		"evaluation/{er}.tsv"
	script:
		"../scripts/evaluate_stellar_search.py"

rule table1:
	input:
                benchmark = "benchmarks/stellar_avg.tsv",
                evaluation = expand("evaluation/{er}.tsv", er=error_rates)

	output:
		"table1.tsv"
	script:
		"../scripts/make_stellar_table1.py"

