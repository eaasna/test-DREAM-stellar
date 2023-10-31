rule stellar_accuracy:
	input:
		search = "stellar/rep{rep}_e{er}.gff",
		truth = "ground_truth/rep{rep}_e{er}.tsv"
	output:
		"evaluation/stellar_rep{rep}_e{er}.tsv"
	params:
		min_overlap = min_overlap
	shell:
		"../scripts/evaluate_search.sh {input.search} {input.truth} {params.min_overlap} {min_len} {output} gff"

rule stellar_table1:
	input:
                benchmark = expand("benchmarks/stellar_rep{rep}_e{er}.txt", rep=repetitions, er=error_rates),
                evaluation = expand("evaluation/stellar_rep{rep}_e{er}.tsv", rep=repetitions, er=error_rates)
	output:
		"stellar_table1.tsv"
	params:
		repeats = n,	# set as parameters to use in .py
		prefix = "stellar",
		error_rates = error_rates
	script:
		"../scripts/make_stellar_table1.py"

rule dream_accuracy:
	input:
		search = "valik/rep{rep}_e{er}.gff",
		truth = "ground_truth/rep{rep}_e{er}.tsv"
	output:
		"evaluation/valik_rep{rep}_e{er}.tsv"
	params:
		min_overlap = min_overlap
	shell:
		"../scripts/evaluate_search.sh {input.search} {input.truth} {params.min_overlap} {min_len} {output} gff"

rule valik_table1:
	input:
                benchmark = expand("benchmarks/valik_rep{rep}_e{er}.txt", rep=repetitions, er=error_rates),
                evaluation = expand("evaluation/valik_rep{rep}_e{er}.tsv", rep=repetitions, er=error_rates)
	output:
		"valik_table1.tsv"
	params:
		repeats = n,	# set as parameters to use in .py,
		prefix = "valik",
		error_rates = error_rates
	script:
		"../scripts/make_stellar_table1.py"

rule blast_accuracy:
	input:
		search = "blast/rep{rep}_e{er}.tsv",
		truth = "ground_truth/rep{rep}_e{er}.tsv"
	output:
		"evaluation/blast_rep{rep}_e{er}.tsv"
	params:
		min_overlap = min_overlap
	shell:
		"../scripts/evaluate_search.sh {input.search} {input.truth} {params.min_overlap} {min_len} {output} tsv"

rule blast_table1:
	input:
                benchmark = expand("benchmarks/blast_rep{rep}_e{er}.txt", rep=repetitions, er=error_rates),
                evaluation = expand("evaluation/blast_rep{rep}_e{er}.tsv", rep=repetitions, er=error_rates)
	output:
		"blast_table1.tsv"
	params:
		repeats = n,	# set as parameters to use in .py
		prefix = "blast",
		error_rates = error_rates
	script:
		"../scripts/make_stellar_table1.py"
