rule benchmark_average:
	input:
		expand("benchmarks/stellar_{er}.txt", er=error_rates)
	output:
		avg = "benchmarks/stellar_avg.tsv"
	script:
		"../scripts/run_time_average.py"
	
