rule benchmark_average:
	input:
		expand("benchmarks/stellar_{er}.txt", er=error_rates)
	output:
		avg = "benchmarks/stellar_avg.tsv"
	script:
		"../scripts/run_time_average.py"

rule stellar_accuracy:
	input:
		stellar = "stellar/{er}.gff",
		truth = "ground_truth/{er}.tsv"
	output:
		"evaluation/{er}.txt"
	script:
		"../scripts/evaluate_stellar_search.py"

